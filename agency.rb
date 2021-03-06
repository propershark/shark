require 'json'
require 'yaml'

require 'rufus-scheduler'

require_relative 'schemable'
require_relative 'configurable'
require_relative 'configurable/configuration'
require_relative 'configurable/agency_configuration'
require_relative 'exceptions'
require_relative 'core_ext/hash'
require_relative 'core_ext/string'
require_relative 'event'
require_relative 'object'
require_relative 'objects/vehicle'
require_relative 'objects/route'
require_relative 'objects/station'
require_relative 'object_manager'
require_relative 'storage'
require_relative 'middleware'


module Shark
  class Agency < Shark::Middleware
    class << self
      include Configurable
      use_configuration_type AgencyConfiguration
    end

    include Configurable
    inherit_configuration_from self


    # The scheduler used to schedule events (e.g., updates) for this Agency
    attr_accessor :scheduler
    # The ObjectManager instances for the services provided by this Agency
    attr_accessor :managers


    def initialize
      @scheduler = Rufus::Scheduler.new
      create_managers
    end


    # "Start" this agency by scheduling all activities that it performs to run
    # in the background (via the scheduler)
    def run
      schedule_managers
    end


    # Initialize all of the object managers defined by the configuration
    def create_managers
      @managers = configuration.managers.each_with_object({}) do |(name, configurator), hash|
        hash[name] = ObjectManager.new(name, self, &configurator)
      end
    end

    # Register the managers with the scheduler to update at the interval
    # defined by their update_frequency.
    def schedule_managers
      @managers.each do |name, manager|
        # Perform one update immediately so that all information is initialized
        # before the first scheduled update cycle occurs. This avoids issues
        # where updates for routes (usually daily) may not have occurred before
        # updates for vehicles (usually every few seconds) need their
        # information.
        manager.update
        @scheduler.every(manager.update_frequency){ manager.update }
      end

      @managers.values.map(&:update)
    end


    # Proxy an event to the middleware stack. Each middleware entry is
    # responsible for passing the event to the next entry, so simply proxying
    # to the first entry is enough.
    def call event
      fire(event)
    end
  end
end
