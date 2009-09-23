# TODO: which require statement to use here? require_dependency breaks stuff
#require 'time_entry'

# Patches Redmine's Users dynamically.
module TimeEntryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable
    end

  end

  module ClassMethods

  end

  module InstanceMethods
    def costs
      @costs || @costs = self.hours * self.user.rate_at(self.spent_on, self.project_id).rate
    rescue
      0.0
    end
    
    def costs=(value)
      @costs = value
    end
    
    def update_costs!(rate)
      @costs = self.hours && rate ? self.hours * rate.rate : 0.0
      @costs.save!
    end
  end
end
