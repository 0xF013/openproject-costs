class OpenProject::Costs::Hooks::ActivityHook < Redmine::Hook::ViewListener
  render_on :activity_index_head,
            :partial => 'hooks/costs/activity_index_head'
end
