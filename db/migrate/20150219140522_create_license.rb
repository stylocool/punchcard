class CreateLicense < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.string      :name
      t.integer     :total_workers
      t.integer     :cost_per_worker
      t.timestamp   :created_at
      t.timestamp   :expired_at
      t.references  :company, index: true
    end
  end
end
