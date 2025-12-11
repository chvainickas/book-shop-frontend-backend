class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :books, through: :cart_items

  def total
    cart_items.sum { |item| item.book.price * item.quantity }
  end

  def item_count
    cart_items.sum(:quantity)
  end
end
