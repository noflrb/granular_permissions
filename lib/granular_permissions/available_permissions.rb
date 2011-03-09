require 'active_support/concern'
module GranularPermissions
  module AvailablePermissions
    extend ActiveSupport::Concern

    included do
      include FlagShihTzu
      validates_presence_of :available
    end

    module ClassMethods
      def has_available_flags(*available_flags)
        available_flags = [available_flags].flatten
        ava_flags = {}

        available_flags.flatten.each_with_index do |flag, index|
          flag = "ava_#{flag.to_s}".to_sym unless flag.to_s =~ /^ava_/
          ava_flags.merge!( {index+1 => flag})
          self.add_accessible_attribute flag
        end

        has_flags(ava_flags, :column => 'available')
      end
    end

    module InstanceMethods
      def available_fields(available = nil)
        fields = []

        self.class.flag_mapping['available'].each do |flag_name, value|
          ava_state = globally_or_locally_available(flag_name)
          case
          when available.nil?
            fields << {flag_name => ava_state}
          when available == true
            fields << flag_name if ava_state
          when available == false
            fields << flag_name unless ava_state
          end
        end
        fields[0].instance_of?(Hash) ?
          fields.sort {|a, b| a.keys[0].to_s <=> b.keys[0].to_s} :
          fields.sort {|a, b| a.to_s <=> b.to_s}
      end

      def globally_or_locally_available(flag_name)
        self.send(flag_name) || globally_available(flag_name)
      end

      def global_permissions
        "Global#{self.class.name.gsub(/^Global/,'')}".constantize.first
      end

      def globally_available(flag_name)
        global_permissions.try(flag_name)
      end

      def has_availables?
        self.class.flag_mapping['available'].present?
      end

    end
  end
end
