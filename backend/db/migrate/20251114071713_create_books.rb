class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.decimal :price, precision: 8, scale: 2
      t.integer :stock
      t.text :description

      t.timestamps
    end
  end
end
