class User < ApplicationRecord
  has_secure_password

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlist_books, through: :wishlist_items, source: :book

  before_save :downcase_email
  after_create :create_cart

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :password, length: { minimum: 6 }, allow_nil: true

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def create_cart
    Cart.create(user: self)
  end
end
