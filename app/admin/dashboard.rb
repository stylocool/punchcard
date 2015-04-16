ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    if current_user.role? :Root
      # show payment
      columns do
        column do
          panel 'Pending Payment' do
            table_for Payment.where("status != 'ack'").limit(20) do
              column('Company') { |p| p.company.name }
              column('Total_Workers') { |p| p.total_workers }
              column('Rate/Mth') { |p| number_to_currency(p.rate_per_month) }
              column('Months of Service') { |p| p.months_of_service }
              column('Amount') { |p| number_to_currency(p.amount) }
              column('Mode') { |p| p.mode }
              column('Reference No.') { |p| p.reference_number }
              column('Status') { |p| p.status }
              column('Created At') { |p| p.created_at }
            end
          end
        end
      end

      # show audit trail
      columns do
        column do
          panel 'Recent Changes' do
            table_for PaperTrail::Version.order('created_at DESC').limit(20) do
              column('Item') { |v| v.item }
              column('Type') { |v| v.item_type.underscore.humanize }
              column('Event') { |v| v.event }
              column('Changes') { |v| v.changeset }
              column('Modified At') { |v| v.created_at }
              column('Modified By') do |v|
                if v.whodunnit.present?
                  user = User.find(v.whodunnit)
                  user.email if user.present?
                end
              end
            end
          end
        end
      end

    elsif current_user.role? :Administrator

      # license check
      if current_user.current_company.license.present?
        # license expired
        if current_user.current_company.license.expired_at < Time.now
          div class: 'blank_slate_container', id: 'dashboard_default_message' do
            span class: 'blank_slate' do
              'License expired!'
            end
            span class: 'blank_slate' do
              link_to 'Renew license', new_admin_payment_path
            end
          end
        elsif current_user.current_company.license.expired_at <= (Time.now - 3.days)
          div class: 'blank_slate_container', id: 'dashboard_default_message' do
            span class: 'blank_slate' do
              "Your license is going to expire in #{distance_of_time_in_words_to_now(current_user.current_company.license.expired_at)}"
            end
            span class: 'blank_slate' do
              link_to 'Renew license', new_admin_payment_path
            end
          end
        end
      end

      if current_user.current_company.present?
        if current_user.current_company.company_setting.present?
          payment = Payment.find_by_company_id(current_user.current_company.id)
          if payment.present?
            project = Project.find_by_company_id(current_user.current_company.id)
            if project.present?
              worker = Worker.find_by_company_id(current_user.current_company.id)
              if worker.present?
                # show audit trail
                columns do
                  column do
                    panel 'Recent Changes' do
                      table_for PaperTrail::Version
                        .where('whodunnit in (select user_id::text from user_companies where company_id = ' + current_user.current_company.id.to_s + ')')
                        .order('created_at DESC').limit(20) do
                        column('Item') { |v| v.item }
                        column('Type') { |v| v.item_type.underscore.humanize }
                        column('Event') { |v| v.event }
                        column('Changes') { |v| v.changeset }
                        column('Modified At') { |v| v.created_at }
                        column('Modified By') do |v|
                          if v.whodunnit.present?
                            user = User.find(v.whodunnit)
                            user.email if user.present?
                          end
                        end
                      end
                    end
                  end
                end
              else
                div class: 'blank_slate_container', id: 'dashboard_default_message' do
                  span class: 'blank_slate' do
                    link_to 'Create worker', new_admin_worker_path
                  end
                end
              end
            else
              div class: 'blank_slate_container', id: 'dashboard_default_message' do
                span class: 'blank_slate' do
                  link_to 'Create project', new_admin_project_path
                end
              end
            end
          else
            div class: 'blank_slate_container', id: 'dashboard_default_message' do
              span class: 'blank_slate' do
                link_to 'Purchase license', new_admin_payment_path
              end
            end
          end
        else
          div class: 'blank_slate_container', id: 'dashboard_default_message' do
            span class: 'blank_slate' do
              link_to 'Create company settings', new_admin_company_setting_path
            end
          end
        end
      else
        div class: 'blank_slate_container', id: 'dashboard_default_message' do
          span class: 'blank_slate' do
            link_to 'Create company', new_admin_company_path
          end
        end
      end
    else
      # show audit trail
      columns do
        column do
          panel 'Recent Changes' do
            table_for PaperTrail::Version.where(whodunnit: current_user.id).order('created_at DESC').limit(20) do
              column('Item') { |v| v.item }
              column('Type') { |v| v.item_type.underscore.humanize }
              column('Event') { |v| v.event }
              column('Changes') { |v| v.changeset }
              column('Modified At') { |v| v.created_at }
              column('Modified By') do |v|
                if v.whodunnit.present?
                  user = User.find(v.whodunnit)
                  user.email if user.present?
                end
              end
            end
          end
        end
      end
    end
  end
end
