class WishlistsController < ApplicationController
  before_action :require_login

  def index
    @wishlist_items = current_user.wishlist_items.includes(:book)
  end

  def add_item
    book = Book.find(params[:book_id])
    wishlist_item = current_user.wishlist_items.build(book: book)

    if wishlist_item.save
      redirect_back fallback_location: root_path, notice: "#{book.title} added to wishlist"
    else
      redirect_back fallback_location: root_path, alert: wishlist_item.errors.full_messages.join(', ')
    end
  end

  def remove_item
    wishlist_item = current_user.wishlist_items.find(params[:id])
    book_title = wishlist_item.book.title
    wishlist_item.destroy
    redirect_back fallback_location: wishlist_path, notice: "#{book_title} removed from wishlist"
  end
end
