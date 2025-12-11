class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :book

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :book_has_sufficient_stock

  def subtotal
    book.price * quantity
  end

  private

  def book_has_sufficient_stock
    if book && quantity && quantity > book.stock
      errors.add(:quantity, "exceeds available stock (#{book.stock} available)")
    end
  end
end
