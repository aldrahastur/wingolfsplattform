Wingolfsplattform::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true  # default: false
  #config.cache_store = :file_store, Rails.root.join("tmp/app_cache")
  config.cache_store = :redis_store, 'redis://localhost:6379/0/', { expires_in: 1.day, namespace: 'development_cache' }
  
  # Care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  # When set to false, compiled assets would be used in development.
  config.assets.debug = true


  # Plugin Reload
  # see: http://stackoverflow.com/questions/5156061/reopening-rails-3-engine-classes-from-parent-app
  # This is to be able to re-open engine classes.
  config.reload_plugins = true


  # Mailer Settings
  config.action_mailer.delivery_method = :letter_opener
  # config.action_mailer.delivery_method = :sendmail
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address: 'smtp.1und1.de',
  #   user_name: 'wingolfsplattform@wingolf.org',
  #   password: '',
  #   domain: 'wingolfsplattform.org',
  #   enable_starttls_auto: true
  # }
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000, protocol: 'https' }

end
