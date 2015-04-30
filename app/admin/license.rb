ActiveAdmin.register License do
  permit_params :name, :total_workers, :cost_per_worker, :company_id, :expired_at

  controller do
    def scoped_collection
      if current_user.role == 'Root'
        License.all.page(params[:page]).per(20)
      else
        if current_user.current_company.license.present?
          License.where(id: current_user.current_company.license.id).page(params[:page]).per(20)
        else
          License.none
        end
      end
    end

    def find_resource
      @license = License.find(params[:id])
      return @license if current_user.role == 'Root'
      if current_user.current_company.present?
        @license.company_id == current_user.current_company.id ? @license : :access_denied
      else
        :access_denied
      end

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
    column :expired_at do |license|
      license.expired_at < Time.now ? content_tag(:div, "#{license.expired_at.strftime('%Y-%m-%d %H:%M:%S')}", style: 'color:red') : content_tag(:div, "#{license.expired_at.strftime('%Y-%m-%d %H:%M:%S')}")
    end
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
      f.input :expired_at, as: :datetime_picker
    end
    f.actions
  end
end
