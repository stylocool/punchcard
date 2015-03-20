class CreatePunchcard < ActiveRecord::Migration
  def change
    create_table :punchcards do |t|
      t.timestamp   :checkin
      t.timestamp   :checkout
      t.string      :checkin_location
      t.string      :checkout_location
      t.integer     :fine
      t.boolean     :cancel_pay
      t.references  :company, index: true
      t.references  :project, index: true
      t.references  :worker, index: true
    end
  end
end
