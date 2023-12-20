# frozen_string_literal: true

module Whiplash
  module Logs
    class Railtie < Rails::Railtie
      initializer "whiplash_app.action_controller" do
        ActiveSupport.on_load(:action_controller) do
          puts "Extending #{self} with YourGemsModuleName::Controller"
          include Whiplash::App::CanonicalHost
        end
      end
    end
  end
end