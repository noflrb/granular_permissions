class CreateGranularPermissions < ActiveRecord::Migration
  def self.up
    create_table "roles", :force => true do |t|
      t.string  "name"
    end

    create_table "permissions", :force => true do |t|
      t.string  "type"
      t.integer "crud",     :default => 0
      t.float   "required", :default => 0.0
      t.integer "role_id"
    end

    add_index "permissions", ["type", "crud", "role_id"], :name => "index_permissions_on_type_and_crud_and_role_id"

    create_table "custom_permissions", :force => true do |t|
      t.string   "name"
      t.string   "value"
      t.integer  "permission_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "custom_permissions", ["permission_id", "name", "value"], :name => "index_custom_permissions_on_permission_id_and_name_and_value"

    add_column 'users', 'role_id', :integer
    add_column 'users', 'is_admin', :boolean
  end

  def self.down
    drop_table 'roles'
    drop_table 'permissions'
    drop_table 'custom_permissions'
    remove_column 'users', 'role_id'
    remove_column 'users', 'is_admin'
    remove_index 'index_custom_permissions_on_permission_id_and_name_and_value'
    remove_index 'index_permissions_on_type_and_crud_and_role_id'
  end
end
