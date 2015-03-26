class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    if user.role? :Root
      can :manage, :all

    elsif user.role? :Administrator

      can [:manage], User, :id => user.id

      if user.current_company.present?
        can [:read, :update, :destroy], Company, :id => user.current_company.id

        if user.current_company.company_setting.present?
          can [:read, :update, :destroy], CompanySetting, :id => user.current_company.company_setting.id
        else
          can [:manage], CompanySetting
        end

        can [:read], License, :company_id => user.current_company.id

        payments = Payment.where(:company_id => user.current_company.id);
        if payments.present? && payments.count > 0
          can [:manage], Payment, :company_id => user.current_company.id
        else
          can [:manage], Payment
        end

        can [:create, :read, :update, :destroy], Project, :company_id => user.current_company.id
        can [:create, :read, :update, :destroy], Punchcard, :company_id => user.current_company.id
        can [:create, :read, :update, :destroy], Worker, :company_id => user.current_company.id
        can :manage, ActiveAdmin::Page, :name => "Payrolls", :namespace_name => "admin"

      else
        can [:manage], Company
      end

      can :read, ActiveAdmin::Page, :name => "Dashboard"

    else
      # normal user
      can [:read, :update], User, :id => user.id

      can [:read], Company, :id => user.current_company.id if user.current_company.present?

      can [:read], CompanySetting, :id => user.current_company.id if user.current_company.present?

      can [:read], Project, :company_id => user.current_company.id if user.current_company.present?

      can [:create, :read], Punchcard, :company_id => user.current_company.id if user.current_company.present?

      can [:create, :read], Worker, :company_id => user.current_company.id if user.current_company.present?

      can :read, ActiveAdmin::Page, :name => "Dashboard"
    end

  end
end
