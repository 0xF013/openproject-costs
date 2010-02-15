require_dependency 'issues_helper'

module CostsIssuesHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      def summarized_cost_entries(cost_entries, create_link=true)
        last_cost_type = ""

        return "-" if cost_entries.blank?
        result = cost_entries.sort_by(&:id).inject(Hash.new) do |result, entry|
          if entry.cost_type.id.to_s == last_cost_type
            result[last_cost_type][:units] += entry.units
          else
            last_cost_type = entry.cost_type.id.to_s

            result[last_cost_type] = {}
            result[last_cost_type][:units] = entry.units
            result[last_cost_type][:unit] = entry.cost_type.unit
            result[last_cost_type][:unit_plural] = entry.cost_type.unit_plural
          end
          result
        end

        str_array = []
        options = {:class => 'icon icon-pieces'}
        result.each do |k, v|
          txt = pluralize(v[:units], v[:unit], v[:unit_plural])
          if create_link
            str_array << link_to(txt, {:controller => 'costlog', :action => 'details', :project_id => @issue.project, :issue_id => @issue, :cost_type_id => k}, options)
          else
            str_array << txt
          end
          options = {} # options apply only for first element
        end
        str_array.join(", ")
      end
    end
  end
  
  module InstanceMethods

  end
end

IssuesHelper.send(:include, CostsIssuesHelperPatch)