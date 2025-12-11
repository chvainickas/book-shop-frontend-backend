# app/controllers/api/v1/carts_controller.rb

module Api
  module V1
    class CartsController < ApplicationController
      before_action :set_cart

      # GET /api/v1/cart
      def show
        cart_items = @cart.cart_items.includes(:book)

        render json: {
          cart: {
            id: @cart.id,
            items: cart_items.map { |item| cart_item_json(item) },
            total: @cart.total.to_f,
            item_count: cart_items.sum(:quantity)
          }
        }, status: :ok
      end

      # POST /api/v1/cart/items
      def add_item
        book = Book.find(params[:book_id])
        cart_item = @cart.cart_items.find_by(book: book)

        if cart_item
          cart_item.quantity += (params[:quantity] || 1).to_i
          if cart_item.save
            render json: {
              message: "Updated #{book.title} quantity in cart",
              cart_item: cart_item_json(cart_item)
            }, status: :ok
          else
            render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
          end
        else
          cart_item = @cart.cart_items.build(book: book, quantity: (params[:quantity] || 1).to_i)
          if cart_item.save
            render json: {
              message: "#{book.title} added to cart",
              cart_item: cart_item_json(cart_item)
            }, status: :created
          else
            render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Book not found' }, status: :not_found
      end

      # PATCH /api/v1/cart/items/:id
      def update_item
        cart_item = @cart.cart_items.find(params[:id])

        if cart_item.update(quantity: params[:quantity])
          render json: {
            message: 'Cart updated successfully',
            cart_item: cart_item_json(cart_item)
          }, status: :ok
        else
          render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Cart item not found' }, status: :not_found
      end

      # DELETE /api/v1/cart/items/:id
      def remove_item
        cart_item = @cart.cart_items.find(params[:id])
        cart_item.destroy
        render json: { message: 'Item removed from cart' }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Cart item not found' }, status: :not_found
      end

      # DELETE /api/v1/cart
      def clear
        @cart.cart_items.destroy_all
        render json: { message: 'Cart cleared' }, status: :ok
      end

      private

      def set_cart
        @cart = current_user.cart || current_user.create_cart
      end

      def cart_item_json(cart_item)
        {
          id: cart_item.id,
          quantity: cart_item.quantity,
          book: {
            id: cart_item.book.id,
            title: cart_item.book.title,
            author: cart_item.book.author,
            price: cart_item.book.price.to_f,
            image_url: cart_item.book.image.attached? ? url_for(cart_item.book.image) : nil
          },
          subtotal: cart_item.subtotal.to_f
        }
      end
    end
  end
end
