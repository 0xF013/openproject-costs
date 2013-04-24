module OpenProject::Costs
  class Engine < ::Rails::Engine
    engine_name :openproject_costs

    initializer "costs.register_hooks" do
      require 'open_project/costs/hooks'
      require 'open_project/costs/hooks/issue_hook'
      require 'open_project/costs/hooks/project_hook'
    end

    config.to_prepare do

      require 'open_project/costs/patches'

      # Model Patches
      require_dependency 'open_project/costs/patches/issue_patch'
      require_dependency 'open_project/costs/patches/project_patch'
      require_dependency 'open_project/costs/patches/query_patch'
      require_dependency 'open_project/costs/patches/user_patch'
      require_dependency 'open_project/costs/patches/time_entry_patch'
      require_dependency 'open_project/costs/patches/version_patch'

      # Controller Patchesopen_project/costs/patches/
      require_dependency 'open_project/costs/patches/application_controller_patch'
      require_dependency 'open_project/costs/patches/issues_controller_patch'
      require_dependency 'open_project/costs/patches/timelog_controller_patch'
      require_dependency 'open_project/costs/patches/projects_controller_patch'

      # Helper Patches
      require_dependency 'open_project/costs/patches/application_helper_patch'
      require_dependency 'open_project/costs/patches/users_helper_patch'
      require_dependency 'open_project/costs/patches/issues_helper_patch'

      require_dependency 'open_project/costs/patches/issue_observer'

      # loading the class so that acts_as_journalized gets registered
      VariableCostObject

      Redmine::Plugin.register :redmine_costs do

        name 'Costs Plugin'
        author 'Holger Just @ finnlabs'
        author_url 'http://finn.de/team#h.just'
        description 'The costs plugin provides basic cost management functionality for Redmine.'
        version '4.0.0'

        requires_redmine :version_or_higher => '0.9'

        settings :default => { 'costs_currency' => 'EUR',
                               'costs_currency_format' => '%n %u' },
                 :partial => 'settings/redmine_costs'


        # register our custom permissions
        project_module :costs_module do
          permission :view_own_hourly_rate, {}
          permission :view_hourly_rates, {}

          permission :edit_own_hourly_rate, {:hourly_rates => [:set_rate, :edit]},
                                            :require => :member
          permission :edit_hourly_rates, {:hourly_rates => [:set_rate, :edit]},
                                         :require => :member
          permission :view_cost_rates, {} # cost item values

          permission :log_own_costs, { :costlog => [:new, :create] },
                                     :require => :loggedin
          permission :log_costs, {:costlog => [:new, :create]},
                                 :require => :member

          permission :edit_own_cost_entries, {:costlog => [:edit, :update, :destroy]},
                                             :require => :loggedin
          permission :edit_cost_entries, {:costlog => [:edit, :update, :destroy]},
                                         :require => :member

          permission :block_tickets, {}, :require => :member
          permission :view_cost_objects, {:cost_objects => [:index, :show]}

          permission :view_cost_entries, { :cost_objects => [:index, :show] }
          permission :view_own_cost_entries, { :cost_objects => [:index, :show] }

          permission :edit_cost_objects, {:cost_objects => [:index, :show, :edit, :destroy, :new]}
        end

        # register additional permissions for the time log
        project_module :time_tracking do
          permission :view_own_time_entries, {:timelog => [:details, :report]}
        end

        view_time_entries = Redmine::AccessControl.permission(:view_time_entries)
        view_time_entries.actions << "cost_reports/index"

        # Menu extensions
        menu :top_menu, :cost_types, {:controller => 'cost_types', :action => 'index'},
          :caption => :cost_types_title, :if => Proc.new { User.current.admin? }

        menu :project_menu, :cost_objects, {:controller => 'cost_objects', :action => 'index'},
          :param => :project_id, :before => :settings, :caption => :cost_objects_title

        menu :project_menu, :new_budget, {:action => 'new', :controller => 'cost_objects' }, :param => :project_id, :caption => :label_cost_object_new, :parent => :cost_objects
        menu :project_menu, :show_all, {:action => 'index', :controller => 'cost_objects' }, :param => :project_id, :caption => :label_view_all_cost_objects, :parent => :cost_objects
      end
    end
  end

end


# Observers
ActiveRecord::Base.observers.push :rate_observer, :default_hourly_rate_observer#, :costs_issue_observer
