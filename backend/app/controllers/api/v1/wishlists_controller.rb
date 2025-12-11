# app/controllers/api/v1/wishlists_controller.rb

module Api
  module V1
    class WishlistsController < ApplicationController
      # GET /api/v1/wishlist
      def index
        wishlist_items = current_user.wishlist_items.includes(:book)

        render json: {
          wishlist_items: wishlist_items.map { |item| wishlist_item_json(item) }
        }, status: :ok
      end

      # POST /api/v1/wishlist/items
      def add_item
        book = Book.find(params[:book_id])
        wishlist_item = current_user.wishlist_items.build(book: book)

        if wishlist_item.save
          render json: {
            message: "#{book.title} added to wishlist",
            wishlist_item: wishlist_item_json(wishlist_item)
          }, status: :created
        else
          render json: { errors: wishlist_item.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Book not found' }, status: :not_found
      end

      # DELETE /api/v1/wishlist/items/:id
      def remove_item
        wishlist_item = current_user.wishlist_items.find(params[:id])
        book_title = wishlist_item.book.title
        wishlist_item.destroy

        render json: { message: "#{book_title} removed from wishlist" }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Wishlist item not found' }, status: :not_found
      end

      private

      def wishlist_item_json(wishlist_item)
        {
          id: wishlist_item.id,
          book: {
            id: wishlist_item.book.id,
            title: wishlist_item.book.title,
            author: wishlist_item.book.author,
            price: wishlist_item.book.price.to_f,
            stock: wishlist_item.book.stock,
            image_url: wishlist_item.book.image.attached? ? url_for(wishlist_item.book.image) : nil
          },
          created_at: wishlist_item.created_at
        }
      end
    end
  end
end
