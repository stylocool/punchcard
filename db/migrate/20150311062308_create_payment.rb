class CreatePayment < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer     :total_workers
      t.integer     :rate_per_month
      t.integer     :months_of_service
      t.integer     :amount
      t.string      :mode
      t.string      :reference_number
      t.string      :status
      t.timestamp   :created_at
      t.references  :company
    end
  end
end
