require_dependency 'query'

# Patches Redmine's Queries dynamically, adding the Cost Object
# to the available query columns
module QueryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      base.add_available_column(QueryColumn.new(:cost_object_subject))
      base.add_available_column(QueryColumn.new(:material_costs))
      base.add_available_column(QueryColumn.new(:labor_costs))
      base.add_available_column(QueryColumn.new(:overall_costs))
      
      alias_method_chain :available_filters, :costs
    end

  end
  
  module ClassMethods
    
    # Setter for +available_columns+ that isn't provided by the core.
    def available_columns=(v)
      self.available_columns = (v)
    end

    # Method to add a column to the +available_columns+ that isn't provided by the core.
    def add_available_column(column)
      self.available_columns << (column)
    end
  end
  
  module InstanceMethods
    
    # Wrapper around the +available_filters+ to add a new Cost Object filter
    def available_filters_with_costs
      @available_filters = available_filters_without_costs
      
      if project
        redmine_costs_filters = {
          "cost_object_id" => {
            :type => :list_optional,
            :order => 14,
            :values => CostObject.find(:all, :conditions => ["project_id IN (?)", project], :order => 'subject ASC').collect { |d| [d.subject, d.id.to_s]}
          },
          "labor_costs" => {
            :type => :integer,
            :order => 15,
          },
          "material_costs" => {
            :type => :integer,
            :order => 16,
          },
          "overall_costs" => {
            :type => :integer,
            :order => 16,
          }
          
        }
          
      else
        redmine_costs_filters = { }
      end
      return @available_filters.merge(redmine_costs_filters)
    end
  end    
end


