class AddCoverUrlToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :cover_url, :string
  end
end
