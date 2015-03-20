class CreateCompany < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string      :name
      t.string      :address
      t.string      :email
      t.string      :telephone
      t.integer     :total_workers
      t.timestamp   :created_at
    end
  end
end