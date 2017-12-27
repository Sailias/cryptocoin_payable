class CreateCurrencyConversions < ActiveRecord::Migration[5.1]
  def change
    create_table :currency_conversions do |t|
      t.integer :currency
      t.decimal :price, precision: 24, scale: 0
      t.integer :coin_type
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
