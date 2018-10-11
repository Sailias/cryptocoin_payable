class CreateCoinPayments < ActiveRecord::Migration[5.1]
  def change
    create_table :coin_payments do |t|
      t.string   :payable_type
      t.integer  :coin_type
      t.integer  :payable_id
      t.string   :currency
      t.string   :reason
      t.integer  :price, limit: 8
      t.decimal  :coin_amount_due, default: 0, precision: 24, scale: 0
      t.string   :address
      t.string   :state, default: 'pending'
      t.datetime :created_at
      t.datetime :updated_at
      t.decimal  :coin_conversion, precision: 24, scale: 0
    end
    add_index :coin_payments, %i[payable_type payable_id]
  end
end
