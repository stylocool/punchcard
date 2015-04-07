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
        can [:read, :update, :destroy], Company, :id => user.current_company.id

        if user.current_company.company_setting.present?
          can [:read, :update, :destroy], CompanySetting, :id => user.current_company.company_setting.id
        else
          can :manage, CompanySetting
        end

        can :read, License, :company_id => user.current_company.id

        payments = Payment.where(:company_id => user.current_company.id);
        if payments.present?
          can [:read, :destroy], Payment, :company_id => user.current_company.id
          can :create, Payment
        else
          can [:create, :read, :destroy], Payment
        end

        projects = Project.find_by_company_id(user.current_company.id)
        if projects.present?
          can [:read, :update, :destroy], Project, :company_id => user.current_company.id
          can :create, Project
        else
          can :manage, Project
        end

        punchcards = Punchcard.find_by_company_id(user.current_company.id)
        if punchcards.present?
          can [:read, :update, :destroy], Punchcard, :company_id => user.current_company.id
          can :create, Punchcard
        else
          can :manage, Punchcard
        end

        workers = Worker.find_by_company_id(user.current_company.id)
        if workers.present?
          can [:read, :update, :destroy], Worker, :company_id => user.current_company.id
          can :create, Worker
        else
          can :manage, Worker
        end

        can :manage, ActiveAdmin::Page, :name => "Payrolls", :namespace_name => "admin"

      else
        can [:manage], Company
      end

      can :read, ActiveAdmin::Page, :name => "Dashboard"

    else

      can [:read, :update], User, :id => user.id

      if user.current_company.present?
        can [:read], Company, :id => user.current_company.id

        if user.current_company.company_setting.present?
          can [:read], CompanySetting, :id => user.current_company.company_setting.id
        end

        projects = Project.find_by_company_id(user.current_company.id)
        if projects.present?
          can [:read], Project, :company_id => user.current_company.id
        end

        punchcards = Punchcard.find_by_company_id(user.current_company.id)
        if punchcards.present?
          can [:read], Punchcard, :company_id => user.current_company.id
          can :create, Punchcard
        else
          can :manage, Punchcard
        end

        workers = Worker.find_by_company_id(user.current_company.id)
        if workers.present?
          can [:read], Worker, :company_id => user.current_company.id
        end

        can :manage, ActiveAdmin::Page, :name => "Payrolls", :namespace_name => "admin"

      end
      can :read, ActiveAdmin::Page, :name => "Dashboard"
    end
  end
end
