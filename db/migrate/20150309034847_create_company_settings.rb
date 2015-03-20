class CreateCompanySettings < ActiveRecord::Migration
  def change
    create_table :company_settings do |t|
      t.string    :name
      t.integer   :rate
      t.integer   :overtime_rate
      t.string    :working_hours
      t.timestamp :created_at
      t.references :company, index: true
    end
  end
end
