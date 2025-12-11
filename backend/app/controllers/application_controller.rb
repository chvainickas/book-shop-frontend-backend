class ApplicationController < ActionController::API
  include Pagy::Backend

  before_action :authorize_request

  def current_user
    @current_user
  end

  def logged_in?
    !!current_user
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def require_admin
    unless admin?
      render json: { error: 'You must be an admin to access this resource' }, status: :forbidden
    end
  end

  private

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      decoded = JsonWebToken.decode(header)
      @current_user = User.find(decoded[:user_id]) if decoded
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError => e
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def authorize_request_optional
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      decoded = JsonWebToken.decode(header) if header
      @current_user = User.find(decoded[:user_id]) if decoded
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError => e
      @current_user = nil
    end
  end

  def not_found
    render json: { error: 'Not found' }, status: :not_found
  end
end
