# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service, :action_mailer ]

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_instiki_session',
    :secret      => '4f7957a5c5208a5ec9936bea914a3efae8bca6425579dfbc1d4ed9de5d19d978b00721430ab6c58d89dae4c67d292dac77822a864277187cb4d799728106fa06'
  }

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  #config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  #config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  config.active_record.observers = :page_observer

  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :sql

#  config.load_paths << "#{RAILS_ROOT}/vendor/plugins/sqlite3-ruby"
end

# Instiki-specific configuration below
require_dependency 'instiki_errors'

require 'jcode'
