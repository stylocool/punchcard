class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    if user.role? :Root
      can :manage, :all

    elsif user.role? :Administrator

      can :manage, User

      if user.current_company.present?
        can :manage, Company, id: user.current_company.id

        if user.current_company.company_setting.present?
          can :manage, CompanySetting, id: user.current_company.company_setting.id
          can :create, CompanySetting
        else
          can :read, CompanySetting, id: user.current_company.company_setting.id
          can :create, CompanySetting
        end

        can :read, License, company_id: user.current_company.id

        payments = Payment.where(company_id: user.current_company.id);
        if payments.present?
          can :manage, Payment, company_id: user.current_company.id
          can :create, Payment
        else
          can :read, Payment, company_id: user.current_company.id
          can :create, Payment
        end

        projects = Project.where(company_id: user.current_company.id)
        if projects.present?
          can :manage, Project, company_id: user.current_company.id
          can :create, Project
        else
          can :read, Project, company_id: user.current_company.id
          can :create, Project
        end

        punchcards = Punchcard.where(company_id: user.current_company.id)
        if punchcards.present?
          can :manage, Punchcard, company_id: user.current_company.id
          can :create, Punchcard
        else
          can :read, Punchcard, company_id: user.current_company.id
          can :create, Punchcard
        end

        workers = Worker.where(company_id: user.current_company.id).count
        if workers > 0
          can :manage, Worker, company_id: user.current_company.id
          # check if no. of workers exceeded license
          if user.current_company.license.present?
            if workers < user.current_company.license.total_workers
              can :create, Worker
            end
          end

          can :manage, ActiveAdmin::Page, name: "Reports", namespace_name: "admin"
          can :manage, ActiveAdmin::Page, name: "Payrolls", namespace_name: "admin"
        else
          can :read, Worker, company_id: user.current_company.id
          can :create, Worker
        end
        can :manage, PaperTrail::Version
      else
        can :read, Company, id: user.current_company.id
        can :create, Company
      end
      can :read, ActiveAdmin::Page, name: "Dashboard"

    elsif user.role? :User

      can [:read, :update], User, id: user.id

      if user.current_company.present?
        can :read, Company, id: user.current_company.id

        if user.current_company.company_setting.present?
          can :read, CompanySetting, id: user.current_company.company_setting.id
        end

        projects = Project.where(company_id: user.current_company.id)
        if projects.present?
          can :read, Project, company_id: user.current_company.id
        end

        punchcards = Punchcard.where(company_id: user.current_company.id)
        if punchcards.present?
          can :read, Punchcard, company_id: user.current_company.id
        end

        workers = Worker.where(company_id: user.current_company.id)
        if workers.present?
          can :read, Worker, company_id: user.current_company.id
        end

        can :manage, ActiveAdmin::Page, name: "Payrolls", namespace_name: "admin"

      end
      can :read, ActiveAdmin::Page, name: "Dashboard"

    elsif user.role? :Scanner
      can [:read, :update], User, id: user.id
      can :read, ActiveAdmin::Page, name: "Dashboard"
    end
  end
end
