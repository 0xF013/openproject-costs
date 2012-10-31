class RemoveGroupUserEnhancements < ActiveRecord::Migration
  def self.up
    remove_column :groups_users, :id
    remove_column :groups_users, :membership_type
    remove_column :member_roles, :membership_type
  end

  def self.down
    add_column :groups_users, :id, :primary_key
    add_column :groups_users, :membership_type, :string, :null => false, :default => 'default'
    add_column :member_roles, :membership_type, :string, :null => false, :default => 'default'
  end
end
