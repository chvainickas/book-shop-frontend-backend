class CartsController < ApplicationController
  before_action :require_login
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:book)
  end

  def add_item
    book = Book.find(params[:book_id])
    cart_item = @cart.cart_items.find_by(book: book)

    if cart_item
      cart_item.quantity += 1
      if cart_item.save
        redirect_to cart_path, notice: "Updated #{book.title} quantity in cart"
      else
        redirect_to book, alert: cart_item.errors.full_messages.join(', ')
      end
    else
      cart_item = @cart.cart_items.build(book: book, quantity: 1)
      if cart_item.save
        redirect_to cart_path, notice: "#{book.title} added to cart"
      else
        redirect_to book, alert: cart_item.errors.full_messages.join(', ')
      end
    end
  end

  def update_item
    cart_item = @cart.cart_items.find(params[:id])
    if cart_item.update(quantity: params[:quantity])
      redirect_to cart_path, notice: 'Cart updated successfully'
    else
      redirect_to cart_path, alert: cart_item.errors.full_messages.join(', ')
    end
  end

  def remove_item
    cart_item = @cart.cart_items.find(params[:id])
    cart_item.destroy
    redirect_to cart_path, notice: 'Item removed from cart'
  end

  def clear
    @cart.cart_items.destroy_all
    redirect_to cart_path, notice: 'Cart cleared'
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end
end
