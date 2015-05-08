class AddRemarksToPunchcard < ActiveRecord::Migration
  def change
    change_table :punchcards do |t|
      t.string  :remarks
    end
  end
end
