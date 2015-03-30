Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true  
  
  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Caching
  config.action_controller.perform_caching = true
  # config.cache_store = :file_store, Rails.root.join("tmp/app_cache")
  config.cache_store = :redis_store, "redis://localhost:6379/0/", { expires_in: 1.week, namespace: "#{::STAGE}_cache" }

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_assets = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # This uses a redirect and does not set the default protocol for hyperlinks.
  # For wingolfsplattform, the redirect is already done via nginx.
  #
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify
  
  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false
  
  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
  
  
  # Load Secret Settings
  # -> moved to config/application.rb
  
  if ::STAGE.to_s.include? 'master'
    config.asset_host = 'http://master.wingolfsplattform.org'
  elsif ::STAGE.to_s.include? 'sandbox'
    config.asset_host = 'http://sandbox.wingolfsplattform.org'
  else
    config.asset_host = 'https://wingolfsplattform.org'
  end
  
  # SMTP Settings
  config.action_mailer.delivery_method = :smtp

  smtp_password = ::SECRETS["wingolfsplattform@wingolf.org_smtp_password"]
  unless smtp_password
    raise "
      No smtp password set in config/secrets.yml.
      Please have a look at config/secrets.yml.example and set the key
        wingolfsplattform@wingolf.org_smtp_password
      in config/secrets.yml.
    "
  end

  config.action_mailer.smtp_settings = {
    address: 'smtp.1und1.de',
    user_name: 'wingolfsplattform@wingolf.org',
    password: smtp_password,
    domain: 'wingolfsplattform.org',
    enable_starttls_auto: true,
    # only if certificate malfunctions:
    # openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  
  # Rails-4 syntax:  (see http://stackoverflow.com/a/12609856/2066546)
  #   config.action_mailer.default_options = {    
  #     from: 'Wingolfsplattform <wingolfsplattform@wingolf.org>'
  #   }
  # Rails-3 syntax:
  ActionMailer::Base.default from: 'Wingolfsplattform <wingolfsplattform@wingolf.org>'
  
  config.action_mailer.default_url_options = { host: 'wingolfsplattform.org', protocol: 'https' }

end
