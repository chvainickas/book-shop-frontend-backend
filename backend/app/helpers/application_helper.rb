module ApplicationHelper
  include Pagy::Frontend

  def in_wishlist?(book)
    return false unless logged_in?
    current_user.wishlist_items.exists?(book_id: book.id)
  end
end
