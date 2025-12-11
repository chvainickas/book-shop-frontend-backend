# app/controllers/api/v1/orders_controller.rb

module Api
  module V1
    class OrdersController < ApplicationController
      before_action :set_order, only: [:show]

      # GET /api/v1/orders
      def index
        orders = current_user.orders.order(created_at: :desc)

        render json: {
          orders: orders.map { |order| order_summary_json(order) }
        }, status: :ok
      end

      # GET /api/v1/orders/:id
      def show
        render json: { order: order_json(@order) }, status: :ok
      end

      # POST /api/v1/orders
      def create
        cart = current_user.cart

        if cart.cart_items.empty?
          render json: { error: 'Your cart is empty' }, status: :unprocessable_entity
          return
        end

        # Check stock availability
        out_of_stock = cart.cart_items.select { |item| item.quantity > item.book.stock }
        if out_of_stock.any?
          render json: {
            error: 'Some items in your cart are out of stock',
            out_of_stock_items: out_of_stock.map { |item| { book_id: item.book.id, title: item.book.title } }
          }, status: :unprocessable_entity
          return
        end

        ActiveRecord::Base.transaction do
          # Create order
          order = current_user.orders.build(total: cart.total, status: 'pending')

          if order.save
            # Create order items from cart items
            cart.cart_items.each do |cart_item|
              book = cart_item.book

              # Check stock again
              if cart_item.quantity > book.stock
                raise ActiveRecord::Rollback, "#{book.title} is out of stock"
              end

              # Create order item
              order.order_items.create!(
                book: book,
                quantity: cart_item.quantity,
                price: book.price
              )

              # Reduce stock
              book.update!(stock: book.stock - cart_item.quantity)
            end

            # Clear cart
            cart.cart_items.destroy_all

            # Mark order as completed
            order.update!(status: 'completed')

            render json: {
              message: 'Order placed successfully!',
              order: order_json(order)
            }, status: :created
          else
            render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: "Order failed: #{e.message}" }, status: :unprocessable_entity
      end

      private

      def set_order
        @order = current_user.orders.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end

      def order_summary_json(order)
        {
          id: order.id,
          total: order.total.to_f,
          status: order.status,
          items_count: order.order_items.count,
          created_at: order.created_at,
          updated_at: order.updated_at
        }
      end

      def order_json(order)
        {
          id: order.id,
          total: order.total.to_f,
          status: order.status,
          items: order.order_items.includes(:book).map { |item| order_item_json(item) },
          created_at: order.created_at,
          updated_at: order.updated_at
        }
      end

      def order_item_json(order_item)
        {
          id: order_item.id,
          quantity: order_item.quantity,
          price: order_item.price.to_f,
          book: {
            id: order_item.book.id,
            title: order_item.book.title,
            author: order_item.book.author,
            image_url: order_item.book.image.attached? ? url_for(order_item.book.image) : nil
          },
          subtotal: (order_item.quantity * order_item.price).to_f
        }
      end
    end
  end
end
