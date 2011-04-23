require 'active_support/concern'
require "granular_permissions/crud_permissions"
require "granular_permissions/require_permissions"
require "granular_permissions/available_permissions"
require "granular_permissions/custom_permissions"

module GranularPermissions
  extend ActiveSupport::Concern
  include CrudPermissions
  include RequirePermissions
  include AvailablePermissions
  include CustomPermissions

  included do
    add_accessible_attributes :role_id, :type
  end

  module InstanceMethods
    def type_name
      type.gsub(/Permissions::/,'')
    end

    def execute_extra_validations(permissible_object)
      true
    end
  end

  module ClassMethods
    def has_all_permission_flags(*args)
      has_available_flags(*args)
      has_required_flags(*args)
    end
  end
end
