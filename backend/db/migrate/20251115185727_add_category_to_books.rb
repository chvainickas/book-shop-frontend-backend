class AddCategoryToBooks < ActiveRecord::Migration[8.1]
  def change
    add_reference :books, :category, null: true, foreign_key: true
  end
end
