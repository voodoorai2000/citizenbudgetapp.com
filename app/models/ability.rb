class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    user ||= AdminUser.new
    case user.role
    when 'superuser'
      can :manage, :all
    when 'administrator'
      # Can always read questionnaires that user owns.
      can :read, Questionnaire, id: user.organization.questionnaire_ids
      # Can manage future questionnaires that user owns.
      can [:create, :update, :destroy], Questionnaire, id: user.organization.questionnaire_ids, :starts_at.ne => nil, :starts_at.gt => Time.now
    end
  end
end
