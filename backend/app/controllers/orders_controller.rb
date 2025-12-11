class OrdersController < ApplicationController
  before_action :require_login

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def new
    @cart = current_user.cart
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: 'Your cart is empty'
      return
    end

    # Check stock availability
    out_of_stock = @cart.cart_items.select { |item| item.quantity > item.book.stock }
    if out_of_stock.any?
      redirect_to cart_path, alert: 'Some items in your cart are out of stock. Please update quantities.'
      return
    end

    @order = Order.new
  end

  def create
    @cart = current_user.cart

    if @cart.cart_items.empty?
      redirect_to cart_path, alert: 'Your cart is empty'
      return
    end

    ActiveRecord::Base.transaction do
      # Create order
      @order = current_user.orders.build(total: @cart.total, status: 'pending')

      if @order.save
        # Create order items from cart items
        @cart.cart_items.each do |cart_item|
          book = cart_item.book

          # Check stock again
          if cart_item.quantity > book.stock
            raise ActiveRecord::Rollback, "#{book.title} is out of stock"
          end

          # Create order item
          @order.order_items.create!(
            book: book,
            quantity: cart_item.quantity,
            price: book.price
          )

          # Reduce stock
          book.update!(stock: book.stock - cart_item.quantity)
        end

        # Clear cart
        @cart.cart_items.destroy_all

        # Mark order as completed
        @order.update!(status: 'completed')

        redirect_to order_path(@order), notice: 'Order placed successfully!'
      else
        redirect_to cart_path, alert: 'Failed to create order'
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to cart_path, alert: "Order failed: #{e.message}"
  end
end
