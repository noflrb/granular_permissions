class Permission < ActiveRecord::Base
  include GranularPermissions::FlagShihTzu

  class_attribute :custom_values, :additional_attributes

  belongs_to :role
  has_many :custom_permissions
  validates_presence_of :type, :crud
  validates_uniqueness_of :type, :scope => :role_id
  default_scope includes(:custom_permissions)


  has_flags 1 => :can_read,
            2 => :can_edit,
            3 => :can_create,
            4 => :can_destroy,
            :column => 'crud'

  after_save :set_custom_value_ids

  def self.set_custom_values=(ordered_hash)

    self.custom_values=  ordered_hash

    ordered_hash.each do |custom_name, custom_type|
      class_eval <<-RUBY
        self.additional_attributes ||= []
        self.additional_attributes << "#{custom_name}"

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

      class_eval <<-RUBY
        attr_accessible(*[:crud,
                        :can_read,
                        :can_edit,
                        :can_create,
                        :role_id,
                        :can_destroy, :type] + self.additional_attributes)
        RUBY
  end

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

  def type_name
    type.gsub(/Permissions::/, '')
  end

  def required_fields(required = nil)
    fields = []

    self.class.flag_mapping['required'].each do |flag_name, value|
      case 
      when required.nil?
        fields << {flag_name => self.send(flag_name)}
      when required == true
        fields << flag_name if self.send(flag_name)
      when required == false
        fields << flag_name unless self.send(flag_name)
      end
    end
    fields
  end

  def has_requires?
    self.class.flag_mapping['required'].present?
  end

  def execute_extra_validations(permissible_object)
    true
  end
end
