ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  #content title: proc{ I18n.t("active_admin.dashboard") } do
    #div class: "blank_slate_container", id: "dashboard_default_message" do
    #  span class: "blank_slate" do
    #    span I18n.t("active_admin.dashboard_welcome.welcome")
    #    small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #  end
    #end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  #end # content

  content title: "Recently updated content" do
    table_for PaperTrail::Version.order('id desc').limit(20) do # Use PaperTrail::Version if this throws an error
      column ("Item") { |v| link_to v.item, [:admin, v.item] } # Uncomment to display as link
      column ("Type") { |v| v.item_type.underscore.humanize }
      column ("Modified At") { |v| v.created_at.to_s :long }
      column ("Modified By") do |v| #{ |v| link_to User.find(v.whodunnit).email, [:admin, User.find(v.whodunnit)] }
        if v.whodunnit.present?
          link_to User.find(v.whodunnit).email, [:admin, User.find(v.whodunnit)]
        end
      end
    end
  end
end
