class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :books, through: :order_items

  validates :status, presence: true, inclusion: { in: %w[pending completed cancelled] }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :cancelled, -> { where(status: 'cancelled') }
end
