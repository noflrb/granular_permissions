module GranularPermissions
  class MigrationsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    def generate_migration
      migration_template 'create_granular_permissions.rb.erb', "db/migrate/create_granular_permissions.rb"
    end

    def initializers
      template 'permission_flags.rb', 'config/initializers/permission_flags.rb'
    end

    def self.next_migration_number(dirname)
      Time.now.strftime('%Y%m%d%H%M%S')
    end
  end
end
