ActiveAdmin.register PaperTrail::Version, as: "Audit Trail" do

  controller do
    def scoped_collection
      if current_user.role == 'Root'
        PaperTrail::Version.all.page(params[:page]).per(20)
      elsif current_user.role == 'Administrator'
        PaperTrail::Version.where('whodunnit in (select user_id::text from user_companies where company_id = ' + current_user.current_company.id.to_s + ')').order('id desc').page(params[:page]).per(20)
      end
    end

    def rollback
      v = PaperTrail::Version.find(params[:id])

      case v.event
        when 'create'
          object = get_object(v.item_id, v.item_type)
          object.destroy
          msg = "Version Id [#{v.id}] Type [#{v.item_type}] destroyed!"
        when 'update'
          object = get_object(v.item_id, v.item_type)
          object = object.versions.last
          object.save
          msg = "Version Id [#{v.id}] Type [#{v.item_type}] rollbacked!"
        when 'destroy'
          v.reify(has_one: true, has_many: true).save!
          msg = "Version Id [#{v.id}] Type [#{v.item_type}] undeleted!"
      end

      redirect_to admin_audit_trails_path, notice: msg
    end

    def find_by_item_type_and_item_id
      @versions = PaperTrail::Version.where(item_id: params[:item_id], item_type: params[:item_type]).order('id desc')
      @page_title = 'History'
      render 'layouts/history'
    end

    def get_object(item_id, item_type)
      case item_type
        when 'Company'
          Company.find(item_id)
        when 'CompanySetting'
          CompanySetting.find(item_id)
        when 'License'
          License.find(item_id)
        when 'Payment'
          Payment.find(item_id)
        when 'Project'
          Project.find(item_id)
        when 'Punchcard'
          Punchcard.find(item_id)
        when 'User'
          User.find(item_id)
        when 'Worker'
          Worker.find(item_id)
      end
    end
  end

  scope :all, default: true
  scope :today do |versions|
    versions.where("created_at >= ?", Time.now.beginning_of_day)
  end

  index do
    selectable_column
    id_column
    column :item_type
    column :event
    column 'Object/Changes', :object do |v|
      if v.event == 'destroy'
        v.object
      else
        v.changeset
      end
    end
    column :modified_at do |v|
      v.created_at.strftime('%Y-%m-%d %H:%M:%S')
    end
    column :modified_by do |v|
      if v.whodunnit.present?
        user = User.find(v.whodunnit)
        user.email if user.present?
      end
    end
    actions defaults: false do |v|
      link_to 'Rollback', "audit_trails/#{v.id}/rollback", data: { confirm: 'Are you sure you want to rollback this?' }
    end
  end

  filter :item_type
  filter :event, as: :select, collections: { create: 'create', update: 'update', destroy: 'destroy' }

end