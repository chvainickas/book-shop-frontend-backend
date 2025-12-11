class CreateWishlistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :wishlist_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end

    add_index :wishlist_items, [:user_id, :book_id], unique: true
  end
end
