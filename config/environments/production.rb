# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  # config.public_file_server.enabled = false

  # Compress CSS using a preprocessor.
  #

  # Do not fall back to assets pipeline if a precompiled asset is missed.

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.asset_host = ENV["RAILS_ASSET_HOST"] if ENV["RAILS_ASSET_HOST"].present?

  config.cors_enabled = Decidim::Env.new("DECIDIM_CORS_ENABLED").to_boolean_string

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = Decidim::Env.new("STORAGE_PROVIDER", "local").to_s

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path =~ /health_check/ } } }

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    config.logger = ActiveSupport::Logger.new($stdout)
                                         .tap { |logger| logger.formatter = Logger::Formatter.new }
                                         .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
end

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]
  config.action_mailer.smtp_settings = {
    :address => Decidim::Env.new("SMTP_ADDRESS").to_s,
    :port => Decidim::Env.new("SMTP_PORT", 587).to_i,
    :authentication => Decidim::Env.new("SMTP_AUTHENTICATION", "plain").to_s,
    :user_name => Decidim::Env.new("SMTP_USERNAME").to_s,
    :password => Decidim::Env.new("SMTP_PASSWORD").to_s,
    :domain => Decidim::Env.new("SMTP_DOMAIN").to_s,
    :enable_starttls_auto => Decidim::Env.new("SMTP_STARTTLS_AUTO").to_boolean_string,
    :openssl_verify_mode => "none"
  }

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "decidim_impd_production"

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
  #
  if Decidim::Env.new("MAPS_PROVIDER").present? && Decidim::Env.new("MAPS_STATIC_PROVIDER", ENV.fetch("MAPS_PROVIDER", nil)).to_s.present?
    static_provider = Decidim::Env.new("MAPS_STATIC_PROVIDER", ENV.fetch("MAPS_PROVIDER", nil)).to_s
    dynamic_provider = Decidim::Env.new("MAPS_DYNAMIC_PROVIDER", ENV.fetch("MAPS_PROVIDER", nil)).to_s
    dynamic_url = Decidim::Env.new("MAPS_DYNAMIC_URL")
    static_url = Decidim::Env.new("MAPS_STATIC_URL")
    static_url = "https://image.maps.hereapi.com/mia/v3/base/mc/overlay" if static_provider == "here" && static_url.blank?
    config.maps = {
      provider: static_provider,
      api_key: Decidim::Env.new("MAPS_STATIC_API_KEY", ENV.fetch("MAPS_API_KEY", nil)).to_s,
      static: { url: static_url },
      dynamic: {
        provider: dynamic_provider,
        api_key: Decidim::Env.new("MAPS_DYNAMIC_API_KEY", ENV.fetch("MAPS_API_KEY", nil)).to_s
      }
    }
    config.maps[:geocoding] = { host: Decidim::Env.new("MAPS_GEOCODING_HOST") } if Decidim::Env.new("MAPS_GEOCODING_HOST").present?
    config.maps[:dynamic][:tile_layer] = {}
    config.maps[:dynamic][:tile_layer][:url] = dynamic_url if dynamic_url
    config.maps[:dynamic][:tile_layer][:attribution] = Decidim::Env.new("MAPS_ATTRIBUTION").to_json if Decidim::Env.new("MAPS_ATTRIBUTION").present?
    if Decidim::Env.new("MAPS_EXTRA_VARS").present?
      vars = URI.decode_www_form(Rails.application.secrets.maps[:extra_vars])
      vars.each do |key, value|
        # perform a naive type conversion
        config.maps[:dynamic][:tile_layer][key] = case value
                                                  when /^true$|^false$/i
                                                    value.downcase == "true"
                                                  when /\A[-+]?\d+\z/
                                                    value.to_i
                                                  else
                                                    value
                                                  end
      end
    end
  end
end
