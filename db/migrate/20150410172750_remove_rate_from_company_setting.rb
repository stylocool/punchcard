class RemoveRateFromCompanySetting < ActiveRecord::Migration
  def change
    change_table :company_settings do |t|
      remove_column :company_settings, :rate
    end
  end
end
