class CreateCompanySettings < ActiveRecord::Migration
  def change
    create_table :company_settings do |t|
      t.string    :name
      t.float     :rate
      t.float     :overtime_rate
      t.integer   :working_hours
      t.boolean   :lunch_hour
      t.boolean   :dinner_hour
      t.float     :distance_check
      t.timestamp :created_at
      t.references :company, index: true
    end
  end
end
