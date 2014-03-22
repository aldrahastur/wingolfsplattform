# This class defines the authorization rules.
# It uses the 'cancan' gem: https://github.com/ryanb/cancan
#
# ATTENTION: This class definition below overrides the your_platform rules, which can be found at
# your_platform/app/models/ability.rb
#
class Ability
  include CanCan::Ability

  def initialize(user, options = {})
    preview_as_user = true if options[:preview_as_user]
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    alias_action :create, :read, :update, :destroy, :to => :crud

    # This behaviour is temporary!
    #
    # Only registered users can do or see anything.
    #
    if user

      # Only global administrators can change anything.
      #
      if (not preview_as_user) and Group.find_everyone_group.try(:find_admins) and user.in?(Group.find_everyone_group.find_admins)
        can :manage, :all

      else

        # Users that are no admins can read all and edit their own profile.
        #can :read, :all
        can :download, :all
        can :crud, User, :id => user.id

        cannot :read, ProfileField do |field|
          parent_field = field
          while parent_field.parent != nil do
            parent_field = parent_field.parent
          end

          is_bank_account = parent_field.type == ProfileFieldTypes::BankAccount.name
          is_foreign_bank_account = (is_bank_account && parent_field.profileable.id != user.id)
          is_foreign_bank_account || cannot?(:read, parent_field.profileable)
        end

        can :crud, ProfileField do |field|
          parent_field = field
          while parent_field.parent != nil do
            parent_field = parent_field.parent
          end

          !parent_field.profileable || parent_field.profileable.id == user.id
        end

        # Normal users cannot see hidden users, except for self.
        can :read, User, User.alive? do |user_to_show|
          #puts "blubb"
          #!((user_to_show.hidden?  || !user_to_show.alive?) && (user != user_to_show))
          user_to_show.alive?
        end

        # Normal users cannot see the former_members_parent groups
        # and their descendant groups.
        cannot :read, Group do |group|
          group.has_flag?(:former_members_parent) || group.ancestor_groups.find_all_by_flag(:former_members_parent).count > 0
        end

        # LOCAL ADMINS
        # Local admins can manage their groups, this groups' subgroups 
        # and all users within their groups. They can also execute workflows.
        #
          unless preview_as_user
          can :manage, Group do |group|
            (group.find_admins.include?(user)) || (group.ancestors.collect { |ancestor| ancestor.find_admins }.flatten.include?(user))
            # group.cached_structurable_admins.include?(user)
          end
          can :manage, User do |other_user|
            other_user.ancestor_groups.collect { |ancestor| ancestor.find_admins }.flatten.include?(user)
            # other_user.user_admins.include?(user)
          end
          can :execute, Workflow do |workflow|
            workflow.ancestor_groups.collect { |ancestor| ancestor.find_admins }.flatten.include?(user)
          end
          can :manage, Page do |page|
            page.find_admins.include?(user) || page.ancestors.collect { |ancestor| ancestor.find_admins }.flatten.include?(user)
            # page.cached_structurable_admins.include?(user)
          end
        end
        
        # DEVELOPERS
        if user.developer?
          can :use, Rack::MiniProfiler
        end

      end

    end
    
    # Imprint
    # Make sure all users (even if not logged in) can read the imprint.
    can :read, Page do |page|
      page.has_flag? :imprint
    end
    
  end
end
