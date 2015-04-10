ActiveAdmin.register License do
  permit_params :name, :total_workers, :cost_per_worker, :company_id, :expired_at

  controller do
    def find_resource
      @license = License.where(id: params[:id]).first!
      return @license if current_user.role? :Root
      @license.company_id == current_user.company.id ? @license : :access_denied
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :total_workers
    column :cost_per_worker
    column :company
    column :created_at
    column :expired_at
    actions
  end

  filter :name

  form do |f|
    f.inputs 'License Details' do
      f.input :name
      f.input :total_workers, as: :number
      f.input :cost_per_worker, as: :number
      f.input :company, as: :select, include_blank: false, collection:
                          Company.all.map { |u| ["#{u.name}", u.id] }
      f.input :expired_at, as: :datepicker
    end
    f.actions
  end
end
