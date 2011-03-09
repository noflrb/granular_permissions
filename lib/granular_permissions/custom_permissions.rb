require 'active_support/concern'
module GranularPermissions
  module CustomPermissions
    extend ActiveSupport::Concern

    included do
      include FlagShihTzu
      has_many :custom_permissions
      class_attribute :custom_values
      after_save :set_custom_value_ids
      default_scope includes(:custom_permissions)
    end

    module ClassMethods

      def set_custom_values=(ordered_hash)

        self.custom_values=  ordered_hash

        ordered_hash.each do |custom_name, custom_type|
          class_eval <<-RUBY
            self.add_accessible_attribute "#{custom_name}"

              def #{custom_name}
                value = custom_permissions.
                          where(:name => "#{custom_name}").
                          order("updated_at DESC").
                          try(:first).
                          try(:value)
                convert(value, :to => "#{custom_type}")
              end

              def #{custom_name}=(value)
                cp = CustomPermission.find_or_initialize_by_permission_id_and_name(self.id, "#{custom_name}")
                cp.value = value

                if cp.save
                  @custom_value_ids ||= []
                  @custom_value_ids << cp.id unless @custom_value_ids.include?(cp.id)
                end
              end
            RUBY
          end
      end
    end

    module InstanceMethods
      def set_custom_value_ids
        unless @custom_value_ids.blank?
          CustomPermission.update_all(["permission_id = ?", self.id], "id in (#{@custom_value_ids.join(',')})")
        end
      end

      def convert(value, options)
        case options[:to]
        when 'String'
          value.to_s
        when 'Integer'
          value.to_i
        when 'Boolean'
          value =~ /true|t|1/ ? true : false
        else
          value
        end
      end

      def converted_custom_values
        changed? ?
          @converted_custom_values   = get_converted_custom_values :
          @converted_custom_values ||= get_converted_custom_values
      end

      def get_converted_custom_values
        if self.class.custom_values
          names_and_values = self.class.custom_values.keys.map do |custom_variable_name|
            [custom_variable_name, {:type => self.class.custom_values[custom_variable_name], :value => send(custom_variable_name)}]
          end
        else
          names_and_values = []
        end
        ActiveSupport::OrderedHash.new.merge(names_and_values)
      end
    end
  end
end
