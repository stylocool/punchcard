class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    if user.role? :Root
      can :manage, :all

    elsif user.role? :Administrator

      can [:manage], User

      can [:manage], Company, :id => user.current_company.id

      can [:create, :read, :update], CompanySetting, :company_id => user.current_company.id if user.current_company.present?

      can [:read], License, :company_id => user.current_company.id

      can [:create, :read], Payment, :company_id => user.current_company.id

      can [:create, :read, :update], Project, :company_id => user.current_company.id

      can [:create, :read, :update], Punchcard, :company_id => user.current_company.id

      can [:create, :read, :update], Worker, :company_id => user.current_company.id

      can :manage, ActiveAdmin::Page, :name => "Payrolls", :namespace_name => "admin"

      can :read, ActiveAdmin::Page, :name => "Dashboard"

    else
      # normal user
      can [:read, :update], User, :id => user.id

      can [:read], Company, :id => user.current_company.id

      can [:read], CompanySetting, :id => user.current_company.id

      can [:read], Project, :company_id => user.current_company.id

      can [:create, :read], Punchcard, :company_id => user.current_company.id

      can [:create, :read], Worker, :company_id => user.current_company.id

      can :read, ActiveAdmin::Page, :name => "Dashboard"
    end

  end
end
