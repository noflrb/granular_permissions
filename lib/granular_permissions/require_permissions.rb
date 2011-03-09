require 'active_support/concern'
module GranularPermissions
  module RequirePermissions
    extend ActiveSupport::Concern

    included do
      include FlagShihTzu
    end

    module ClassMethods
      def has_required_flags(*required_flags)
        required_flags = [required_flags].flatten
        req_flags = {}

        required_flags.flatten.each_with_index do |flag, index|
          flag = "req_#{flag.to_s}".to_sym unless flag.to_s =~ /^req_/
          req_flags.merge!( {index+1 => flag})
          self.add_accessible_attribute flag
        end

        has_flags(req_flags, :column => 'required')
      end
    end

    module InstanceMethods
      def required_fields(required = nil)
        fields = []

        self.class.flag_mapping['required'].each do |flag_name, value|
          req_state = globally_or_locally_required(flag_name)
          case
          when required.nil?
            fields << {flag_name => req_state}
          when required == true
            fields << flag_name if req_state
          when required == false
            fields << flag_name unless req_state
          end
        end
        fields[0].instance_of?(Hash) ?
          fields.sort {|a, b| a.keys[0].to_s <=> b.keys[0].to_s} :
          fields.sort {|a, b| a.to_s <=> b.to_s}
      end

      def globally_or_locally_required(flag_name)
        self.send(flag_name) || globally_required(flag_name)
      end

      def global_permissions
        "Global#{self.class.name.gsub(/^Global/,'')}".constantize.first
      end

      def globally_required(flag_name)
        global_permissions.try(flag_name)
      end

      def has_requires?
        self.class.flag_mapping['required'].present?
      end
    end
  end
end
