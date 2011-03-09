require 'active_support/concern'
module GranularPermissions
  module CrudPermissions
    extend ActiveSupport::Concern

    included do
      include FlagShihTzu
      validates_presence_of :crud
      has_flags 1 => :can_read,
                2 => :can_edit,
                3 => :can_create,
                4 => :can_destroy,
                :column => 'crud'

      add_accessible_attributes(:crud,
                        :can_read,
                        :can_edit,
                        :can_create,
                        :can_destroy)
    end

    module ClassMethods
    end

    module InstanceMethods
      def crud_fields(crud = nil)
        fields = []

        self.class.flag_mapping['crud'].each do |flag_name, value|
          crud_state = self.send(flag_name)
          case
          when crud.nil?
            fields << {flag_name => crud_state}
          when crud == true
            fields << flag_name if crud_state
          when crud == false
            fields << flag_name unless crud_state
          end
        end
        fields[0].instance_of?(Hash) ?
          fields.sort {|a, b| a.keys[0].to_s <=> b.keys[0].to_s} :
          fields.sort {|a, b| a.to_s <=> b.to_s}
      end
    end
  end
end
