ActiveAdmin.register Session do

  index do
    selectable_column
    id_column
    column :session_id
    column :data
    column :created_at
    column :updated_at
    column :expired_at do |session|
      (session.updated_at + 30.minutes).strftime('%Y-%m-%d %H:%M:%S')
    end
    actions
  end

end
