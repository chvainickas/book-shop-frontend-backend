class Book < ApplicationRecord
  has_one_attached :image
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error
  has_many :wishlist_items, dependent: :destroy
  belongs_to :category, optional: true

  validates :title, presence: true
  validates :author, presence: true
  validates :price, presence: true
  validates :description, presence: true
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :search, ->(query) {
    return all if query.blank?

    where("title LIKE ? OR author LIKE ? OR description LIKE ?",
          "%#{query}%", "%#{query}%", "%#{query}%")
  }

  def in_stock?
    stock > 0
  end
end
