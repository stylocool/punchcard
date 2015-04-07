ActiveAdmin.register Worker do
  permit_params :name, :race, :gender, :nationality, :contact, :work_permit, :company_id, :worker_type

  controller do
    #def index
    #  index! do |format|
    #    if current_user.role? :Root
    #      @workers = Worker.all.page(params[:page])
        #elsif current_user.role? :Administrator
    #    else
    #      if current_user.current_company.present?
    #        @workers = Worker.where(:company_id => current_user.current_company.id).page(params[:page])
    #      else
    #        @workers = Worker.none
    #      end
    #    end
    #    format.html
    #  end
    #end

    def find_resource
      @worker = Worker.where(id: params[:id]).first!
      if current_user.role? :Root
        @worker
      else
        if @worker.company_id == current_user.current_company.id
          @worker
        else
          :access_denied
        end
      end
    end
  end

  index do
    selectable_column
    id_column
    column :name do |worker|
      best_in_place worker, :name, :type => :input, :path =>[:admin, worker]
    end
    column :race do |worker|
      best_in_place worker, :race, :type => :select, :path =>[:admin, worker], collection: { Chinese: "Chinese", Indian: "Indian", Malay: "Malay", Others: "Others" }
    end
    column :gender do |worker|
      best_in_place worker, :gender, :type => :select, :path =>[:admin, worker], collection: { Male: "Male", Female: "Female" }
    end
    column :nationality
    column :contact do |worker|
      best_in_place worker, :contact, :type => :input, :path =>[:admin, worker]
    end
    column :work_permit do |worker|
      best_in_place worker, :work_permit, :type => :input, :path =>[:admin, worker]
    end
    column :company
    column :worker_type do |worker|
      best_in_place worker, :worker_type, :type => :select, :path =>[:admin, worker], collection: { Worker: "Worker", Supervisor: "Supervisor" }
    end
    column :created_at
    actions
  end

  filter :name
  filter :race
  filter :gender
  filter :nationality
  filter :work_permit
  filter :company
  filter :worker_type

  form do |f|
      f.inputs "Worker Details" do
      f.input :name
      f.input :race, as: :select, include_blank: false, collection: { Chinese: "Chinese", Indian: "Indian", Malay: "Malay", Others: "Others" }
      f.input :gender, as: :select, include_blank: false, collection: { Male: "Male", Female: "Female" }
      f.input :nationality, as: :country, priority_countries: ["SG", "MY", "IN", "ID"]
      f.input :contact, :as => :number
      f.input :work_permit
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
      f.input :worker_type, as: :select, include_blank: false, collection: { Worker: "Worker", Supervisor: "Supervisor" }
      end
    f.actions
  end

end