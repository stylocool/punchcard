class AddUserToPunchcard < ActiveRecord::Migration
  def change
    change_table :punchcards do |t|
      t.references  :user, index: true
    end
  end
end
