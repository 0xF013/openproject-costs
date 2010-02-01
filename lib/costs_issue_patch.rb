require_dependency 'issue'

module CostsIssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable
      
      belongs_to :cost_object
      has_many :cost_entries, :dependent => :delete_all

      # disabled for now, implements part of ticket blocking
      #alias_method_chain :validate, :cost_object

      def spent_hours
        # overwritten method
        @spent_hours ||= self.time_entries.visible(User.current).sum(:hours) || 0
      end
    end
  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods
    def validate_with_cost_object
      if cost_object_id_changed?
        if cost_object_id_was.nil?
          # formerly unassigned ticket
          errors.add :cost_object_id, :activerecord_error_invalid if cost_object.blocked?
        else
          old_cost_object = CostObject.find(cost_object_id_was)
          errors.add :cost_object_id, :activerecord_error_invalid if old_cost_object.blocked?
        end
      end
      
      validate_without_cost_object
    end
    
    def material_costs
      @material_costs ||= cost_entries.visible_costs(User.current, self.project).sum("CASE
        WHEN #{CostEntry.table_name}.overridden_costs IS NULL THEN
          #{CostEntry.table_name}.costs
        ELSE
          #{CostEntry.table_name}.overridden_costs END").to_f
    end
    
    def labor_costs
      @labor_costs ||= time_entries.visible_costs(User.current, self.project).sum("CASE
        WHEN #{TimeEntry.table_name}.overridden_costs IS NULL THEN
          #{TimeEntry.table_name}.costs
        ELSE
          #{TimeEntry.table_name}.overridden_costs END").to_f
    end
    
    def overall_costs
      labor_costs + material_costs
    end
    
    # Wraps the association to get the Cost Object subject.  Needed for the 
    # Query and filtering
    def cost_object_subject
      unless self.cost_object.nil?
        return self.cost_object.subject
      end
    end
    
    def update_costs!
      # This methods ist referenced from some migrations but does nothing
      # anymore.
    end
  end
end

Issue::SAFE_ATTRIBUTES << "cost_object_id"
Issue.send(:include, CostsIssuePatch)