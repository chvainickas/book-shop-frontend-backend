class BooksController < ApplicationController
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @categories = Category.all
    @books = Book.all

    # Filter by category
    if params[:category_id].present? && params[:category_id] != ""
      @books = @books.where(category_id: params[:category_id])
      @current_category = Category.find_by(id: params[:category_id])
    end

    # Search
    @books = @books.search(params[:query]) if params[:query].present?

    # Sort
    case params[:sort]
    when 'price_low'
      @books = @books.order(price: :asc, created_at: :desc)
    when 'price_high'
      @books = @books.order(price: :desc, created_at: :desc)
    when 'title'
      @books = @books.order(title: :asc)
    when 'newest'
      @books = @books.order(created_at: :desc)
    else
      @books = @books.order(created_at: :desc)
    end

    @pagy, @books = pagy(@books, limit: 12)
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to @book, notice: 'Book was successfully created.'
    else
      render :new
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to @book, notice: 'Book was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path, notice: 'Book was successfully deleted.'
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :price, :stock, :description, :image, :category_id)
  end
end
