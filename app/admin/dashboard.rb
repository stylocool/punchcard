ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    if current_user.role? :Administrator
      unless current_user.current_company.present?
        if current_user.role? :Administrator
          div class: "blank_slate_container", id: "dashboard_default_message" do
            span class: "blank_slate" do
              link_to 'Create a company', new_admin_company_path
            end
          end
        end
      end
    end

    if current_user.role? :Root
      columns do
        column do
          panel "Recent Changes" do
            table_for PaperTrail::Version.limit(20) do # Use PaperTrail::Version if this throws an error
              column ("Item") { |v| v.item } #, [:admin, v.item] }
              column ("Type") { |v| v.item_type.underscore.humanize }
              column ("Event") { |v| v.event }
              column ("Modified At") { |v| v.created_at.to_s :long }
              column ("Modified By") do |v| #{ |v| link_to User.find(v.whodunnit).email, [:admin, User.find(v.whodunnit)] }
                if v.whodunnit.present?
                  user = User.find(v.whodunnit)
                  if user.present?
                    user.email#link_to User.find(v.whodunnit).email, [:admin, User.find(v.whodunnit)]
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
