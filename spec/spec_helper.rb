require 'rubygems'
require 'bundler'
require 'logger'
require 'active_record'
require 'database_cleaner'
require 'rspec'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'granular_permissions'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/support/debug.log')
ActiveRecord::Base.configurations = YAML::load_file(File.dirname(__FILE__) + '/support/database.yml')
ActiveRecord::Base.establish_connection(ENV['DB'] || 'sqlite3')

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false

  load(File.dirname(__FILE__) + '/support/schema.rb')
  load(File.dirname(__FILE__) + '/support/models.rb')
end

RSpec.configure do |config|

end
