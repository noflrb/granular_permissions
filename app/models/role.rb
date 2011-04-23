class Role < ActiveRecord::Base

  PERMISSION_MODELS=[
    'Equipment',
    'WorkOrder',
    'MonthlyLog',
    'FuelCard',
    'User',
    'Report'
  ]

  include Permissible

  belongs_to :agency
  has_many :users
  has_and_belongs_to_many :locations
  has_many :permissions do
    def for(type)
      permissions_class = "Permissions::#{type}".constantize
      permissions_class.find_or_initialize_by_role_id(proxy_owner.id)
    end
  end

  PERMISSION_MODELS.each do |permission_model|
    permission_name = "permissions_#{permission_model.tableize.singularize}".to_sym
    has_one permission_name, :class_name => "Permissions::#{permission_model}"
    accepts_nested_attributes_for permission_name
  end

  default_scope includes(:agency)


  validates_presence_of :name

  delegate :usable_types, :to => :agency

  accepts_nested_attributes_for :permissions

  def selected_locations(new = false)
    Location.select(["locations.id as location_id,locations.name, locations_roles.role_id as role_id"]).
      joins("LEFT OUTER JOIN locations_roles ON locations_roles.location_id = locations.id
                                             AND locations_roles.role_id = #{self.id || 'NULL'}").
      where(["locations.agency_id = ? 
              AND (
                locations_roles.role_id = ? OR
                locations_roles.role_id is NULL)", self.agency_id, self.id]).
      order("locations.name ASC")
  end

  def new_or_existing_usable_types
    usable_types.map {|type| permissions.for(type) }
  end

  def self.options(agency = nil)
    agency ?
      roles = Role.order(:name).where(:agency_id => agency) :
      roles = Role.order(:name)
    [['','']] + roles.map {|role| [role.id, role.name]}
  end
end
