class CreateCoinPaymentTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :coin_payment_transactions do |t|
      t.decimal :estimated_value, precision: 24, scale: 0
      t.string :transaction_hash, index: { unique: true }
      t.string :block_hash
      t.datetime :block_time
      t.datetime :estimated_time
      t.integer :coin_payment_id
      t.decimal :coin_conversion, precision: 24, scale: 0
      t.integer :confirmations, default: 0
    end

    add_index :coin_payment_transactions, :coin_payment_id
  end
end
