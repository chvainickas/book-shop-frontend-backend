# app/controllers/api/v1/books_controller.rb

module Api
  module V1
    class BooksController < ApplicationController
      skip_before_action :authorize_request, only: [:index, :show]
      before_action :require_admin, only: [:create, :update, :destroy]
      before_action :set_book, only: [:show, :update, :destroy]

      # GET /api/v1/books
      def index
        books = Book.includes(:category)

        # Filter by category
        if params[:category_id].present? && params[:category_id] != ""
          books = books.where(category_id: params[:category_id])
        end

        # Search
        books = books.search(params[:query]) if params[:query].present?

        # Sort
        case params[:sort]
        when 'price_low'
          books = books.order(price: :asc, created_at: :desc)
        when 'price_high'
          books = books.order(price: :desc, created_at: :desc)
        when 'title'
          books = books.order(title: :asc)
        when 'newest'
          books = books.order(created_at: :desc)
        else
          books = books.order(created_at: :desc)
        end

        # Pagination
        pagy, books = pagy(books, limit: params[:limit] || 12)

        render json: {
          books: books.map { |book| book_json(book) },
          pagination: {
            current_page: pagy.page,
            total_pages: pagy.pages,
            total_count: pagy.count,
            per_page: pagy.limit
          }
        }, status: :ok
      end

      # GET /api/v1/books/:id
      def show
        render json: { book: book_json(@book) }, status: :ok
      end

      # POST /api/v1/books
      def create
        book = Book.new(book_params)

        if book.save
          render json: { book: book_json(book) }, status: :created
        else
          render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/books/:id
      def update
        if @book.update(book_params)
          render json: { book: book_json(@book) }, status: :ok
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/books/:id
      def destroy
        @book.destroy
        render json: { message: 'Book was successfully deleted' }, status: :ok
      end

      private

      def set_book
        @book = Book.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Book not found' }, status: :not_found
      end

      def book_params
        params.require(:book).permit(:title, :author, :price, :stock, :description, :image, :category_id, :cover_url)
      end

      def book_json(book)
        {
          id: book.id,
          title: book.title,
          author: book.author,
          price: book.price.to_f,
          stock: book.stock,
          description: book.description,
          category: book.category ? { id: book.category.id, name: book.category.name } : nil,
          image_url: book.image.attached? ? url_for(book.image) : book.cover_url,
          created_at: book.created_at,
          updated_at: book.updated_at
        }
      end
    end
  end
end
