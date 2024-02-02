# frozen_string_literal: true

module Whiplash
  class App
    class Railtie < Rails::Railtie

      config.before_configuration do |app|
        # App name/etc, mainly for consistency in logging
        app_name = app.class.module_parent.name.underscore.dasherize
        app.config.environment_key = ENV.fetch('ENVIRONMENT_KEY', Rails.env.to_s)
        app.config.application_key = ENV.fetch('APPLICATION_KEY', app_name)
        app.config.application_name_space = [config.application_key, config.environment_key].join('-')
    
        # session settings
        session_days = 30 
        session_seconds = session_days * 24 * 60 * 60
        session_length = ENV.fetch('SESSION_LENGTH', session_seconds).to_i
        app.config.session_length = session_length
        app.config.session_store :cookie_store, :key => '_session', :expire_after => session_length
      end

      initializer "whiplash_app.action_controller" do
        ActiveSupport.on_load(:action_controller_base) do
          include Whiplash::App::CanonicalHost
          include Whiplash::App::ControllerHelpers
        end
      end

    end
  end
end