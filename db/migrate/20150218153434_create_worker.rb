class CreateWorker < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string      :name
      t.string      :race
      t.string      :gender
      t.string      :nationality
      t.string      :contact
      t.string      :work_permit
      t.string      :worker_type
      t.timestamp   :created_at
      t.references  :company, index: true
    end
  end
end
