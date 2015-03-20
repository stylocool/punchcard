class CreateUserCompany < ActiveRecord::Migration
  def change
    create_table :user_companies do |t|
      t.integer   :user_id
      t.integer   :company_id
      t.timestamp :created_at
    end
  end
end
