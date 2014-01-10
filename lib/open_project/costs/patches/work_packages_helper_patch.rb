require_dependency 'work_packages_helper'

module OpenProject::Costs::Patches::WorkPackagesHelperPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      def cost_work_package_attributes(work_package)
        attributes = []

        attributes << work_package_show_table_row(:cost_object) do
          work_package.cost_object ?
            link_to_cost_object(work_package.cost_object) :
            empty_element_tag
        end
        if User.current.allowed_to?(:view_time_entries, @project) ||
          User.current.allowed_to?(:view_own_time_entries, @project)

          attributes << work_package_show_table_row(:spent_hours) do
            # TODO: put inside controller or model
            summed_hours = @time_entries.sum(&:hours)

            summed_hours > 0 ?
              link_to(l_hours(summed_hours), work_package_time_entries_path(work_package)) :
              empty_element_tag
          end

        end
        attributes << work_package_show_table_row(:overall_costs) do
          @overall_costs.nil? ?
            empty_element_tag :
            number_to_currency(@overall_costs)
        end

        if User.current.allowed_to?(:view_cost_entries, @project) ||
          User.current.allowed_to?(:view_own_cost_entries, @project)

          attributes << work_package_show_table_row(:spent_units) do
            summarized_cost_entries(@cost_entries, work_package)
          end
        end

        attributes
      end

      def summarized_cost_entries(cost_entries, work_package, create_link=true)
        last_cost_type = ""

        return empty_element_tag if cost_entries.blank?
        result = cost_entries.sort_by(&:id).inject(Hash.new) do |result, entry|
          if entry.cost_type == last_cost_type
            result[last_cost_type][:units] += entry.units
          else
            last_cost_type = entry.cost_type

            result[last_cost_type] = {}
            result[last_cost_type][:units] = entry.units
            result[last_cost_type][:unit] = entry.cost_type.unit
            result[last_cost_type][:unit_plural] = entry.cost_type.unit_plural
          end
          result
        end

        str_array = []
        result.each do |k, v|
          txt = pluralize(v[:units], v[:unit], v[:unit_plural])
          if create_link
            # TODO why does this have project_id, work_package_id and cost_type_id params?
            str_array << link_to(txt, { :controller => '/costlog',
                                        :action => 'index',
                                        :project_id => work_package.project,
                                        :work_package_id => work_package,
                                        :cost_type_id => k },
                                        { :title => k.name })
          else
            str_array << "<span title=\"#{h(k.name)}\">#{txt}</span>"
          end
        end
        str_array.join(", ").html_safe
      end

      def work_package_show_attributes_with_costs(work_package)
        original = work_package_show_attributes_without_costs(work_package)

        if @project.module_enabled? :costs_module
          original_without_spent_time = original.keys.each_with_object({}) do |key, hash|
            hash[key] = original[key].reject { |a| a.attribute == :spent_time }
          end

          additions = cost_work_package_attributes(work_package)

          additions.each do |addition|
            if original_without_spent_time[:left].count > original_without_spent_time[:right].count
              original_without_spent_time[:right] << addition
            else
              original_without_spent_time[:left] << addition
            end
          end

          original_without_spent_time.keys.each { |key| original_without_spent_time[key].flatten! }

          original_without_spent_time
        else
          original
        end
      end

      alias_method_chain :work_package_show_attributes, :costs
    end
  end
end

WorkPackagesHelper.send(:include, OpenProject::Costs::Patches::WorkPackagesHelperPatch)
