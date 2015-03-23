ActiveAdmin.register License do
  permit_params :name, :total_workers, :cost_per_worker, :company_id, :expired_at

  controller do
    #def index
    #  index! do |format|
    #    if current_user.role? :Root
    #      @licenses = License.all.page(params[:page])
    #    elsif current_user.role? :Administrator
    #      if current_user.current_company.present?
    #        @licenses = License.where(:company_id => current_user.current_company.id).page(params[:page])
    #      else
    #        @licenses = License.none
    #      end
    #    end
    #    format.html
    #  end
    #end

    def find_resource
      @license = License.where(id: params[:id]).first!
      if current_user.role? :Root
        @license
      else
        if @license.company_id == current_user.company.id
          @license
        else
          :access_denied
        end
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
    column :expired_at
    actions
  end

  filter :name

  form do |f|
      f.inputs "License Details" do
      f.input :name
      f.input :total_workers, :as => :number
      f.input :cost_per_worker, :as => :number
      f.input :company, as: :select, include_blank: false, collection: Company.all.map{|u| ["#{u.name}", u.id]}
      f.input :expired_at, :as => :datepicker
    end
    f.actions
  end

end