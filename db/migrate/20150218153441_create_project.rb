class CreateProject < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string      :name
      t.string      :location
      t.timestamp   :created_at
      t.references  :company, index: true
    end
  end
end
