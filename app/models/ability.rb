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
      # Only superuser can create and destroy questionnaires and update
      # questionnaires once the consultation has begun.
      can :manage, :all
    when 'administrator'
      can :read, ActiveAdmin::Page

      # Can update future questionnaires that user owns.
      can :update, Questionnaire, organization_id: user.organization.id, :starts_at.ne => nil, :starts_at.gt => Time.now

      # Can always read questionnaires that user owns.
      can :read, Questionnaire, organization_id: user.organization.id

      # CanCan has trouble with embedded documents, so we may need to load and
      # authorize resources manually. In this case, we do not scope which
      # sections a user can read.
      # @see https://github.com/ryanb/cancan/issues/319
      can :read, Section
      can :read, Question
    end
  end
end
