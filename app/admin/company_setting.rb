ActiveAdmin.register CompanySetting do

  controller do
    #def index
    #  index! do |format|
    #    if current_user.role? :Root
    #      @company_settings = CompanySetting.all.page(params[:page])
    #    elsif current_user.role? :Administrator
    #      if current_user.current_company.present?
    #        @company_settings = CompanySetting.where(:company_id => current_user.current_company.id).page(params[:page])
    #      else
    #        @company_settings = CompanySetting.none
    #      end
    #    end
    #    format.html
    #  end
    #end

    def find_resource
      @company_setting = CompanySetting.where(id: params[:id]).first!
      if current_user.role? :Root
        @company_setting
      #elsif current_user.role? :Administrator
      else
        if current_user.current_company.present?
          if @company_setting.company_id == current_user.current_company.id
            @company_setting
          else
            :access_denied
          end
        else
          :access_denied
        end
      end
    end
  end

  permit_params :name, :rate, :overtime_rate, :working_hours, :company_id

  index do
    selectable_column
    id_column
    column :working_hours
    column :rate
    column :overtime_rate
    column :company
    column :created_at
    actions
  end

  form do |f|
      f.inputs "Company Settings Details" do
      f.input :name
      f.input :working_hours, label: 'Working Hours/Day (e.g. 8 hours, after which is considered as overtime)'
      f.input :rate, label: 'Rate during working hours'
      f.input :overtime_rate, label: 'Overtime rate outside working hours'
      f.input :company, as: :select, include_blank: false, collection:
                          if current_user.role? :Root
                            Company.all.map{|u| ["#{u.name}", u.id]}
                          elsif current_user.role? :Administrator
                            usercompany = UserCompany.find_by_user_id(current_user.id)
                            if usercompany.present?
                              Company.all.where(:id => usercompany.company_id).map{|u| ["#{u.name}", u.id]}
                            else
                              Company.none
                            end
                          end
    end
    f.actions
  end

end
