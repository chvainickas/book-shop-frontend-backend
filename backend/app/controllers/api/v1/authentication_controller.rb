# app/controllers/api/v1/authentication_controller.rb

module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authorize_request, only: [:login, :signup]

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: login_params[:email].downcase)

        if user&.authenticate(login_params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              admin: user.admin?
            }
          }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/signup
      def signup
        user = User.new(signup_params)
        user.email = user.email.downcase

        if user.save
          token = JsonWebToken.encode(user_id: user.id)
          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              admin: user.admin?
            }
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/auth/me
      def me
        render json: {
          user: {
            id: current_user.id,
            email: current_user.email,
            name: current_user.name,
            admin: current_user.admin?
          }
        }, status: :ok
      end

      private

      def login_params
        params.require(:user).permit(:email, :password)
      end

      def signup_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
