# app/controllers/api/v1/categories_controller.rb

module Api
  module V1
    class CategoriesController < ApplicationController
      skip_before_action :authorize_request

      # GET /api/v1/categories
      def index
        categories = Category.all.order(:name)
        render json: {
          categories: categories.map { |category| category_json(category) }
        }, status: :ok
      end

      # GET /api/v1/categories/:id
      def show
        category = Category.find(params[:id])
        render json: { category: category_json(category) }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Category not found' }, status: :not_found
      end

      private

      def category_json(category)
        {
          id: category.id,
          name: category.name,
          books_count: category.books.count
        }
      end
    end
  end
end
