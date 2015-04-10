class AddTradeBasicPayToWorker < ActiveRecord::Migration
  def change
    change_table :workers do |t|
      t.string  :trade
      t.float   :basic_pay
    end
  end
end
