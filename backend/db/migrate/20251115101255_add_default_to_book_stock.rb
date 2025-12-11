class AddDefaultToBookStock < ActiveRecord::Migration[8.1]
  def change
    change_column_default :books, :stock, from: nil, to: 0
  end
end
