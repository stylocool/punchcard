ActiveAdmin.register UserCompany do
  permit_params :user_id, :company_id

  index do
    selectable_column
    id_column
    column :user_id
    column :company_id
    actions
  end

  filter :user_id
  filter :company_id

  form do |f|
    f.inputs 'User Company Details' do
      f.input :user_id, as: :select, include_blank: false, collection:
                          User.all.map { |u| ["#{u.email}", u.id] }

      f.input :company_id, as: :select, include_blank: false, collection:
                          Company.all.map { |u| ["#{u.name}", u.id] }
    end
    f.actions
  end
end
