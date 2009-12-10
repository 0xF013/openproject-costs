require_dependency 'redmine/access_control'

module CostsAccessControlPatch
  def self.included(base) # :nodoc:
    #base.extend(ClassMethods)
    
    base.class_eval do
      class << self
        def allowed_actions_with_inheritance(permission_name)
          my_actions = allowed_actions_without_inheritance(permission_name)
          my_actions | permission(permission_name).inherits.collect(&:actions)
        end

        alias_method_chain :allowed_actions, :inheritance
      end
    end

  end

  module ClassMethods
  end
end

Redmine::AccessControl.send(:include, CostsAccessControlPatch)

