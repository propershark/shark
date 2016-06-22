require 'yaml'

require 'rufus-scheduler'

require_relative 'object'
require_relative 'objects/vehicle'
require_relative 'objects/route'
require_relative 'objects/station'
require_relative 'object_manager'
require_relative 'sources/citybus'
require_relative 'sources/doublemap'
require_relative 'transport'


module Shark
  class Agency
    # A Hash of configuration data used to define this Agency.
    attr_accessor :config
    # The scheduler used to schedule events (e.g., update managers) for this
    # Agency
    attr_accessor :scheduler
    # The Transport object through which all communications that this Agency
    # makes will take place
    attr_accessor :transport
    # The ObjectManager instances that cover all of the services provided by
    # this Agency
    attr_accessor :managers

    def initialize config: nil, config_file:
      @config = config || YAML.load_file(config_file)
      @scheduler = Rufus::Scheduler.new
      @managers = {}
      create_transport
      create_managers
    end

    # "Start" this agency by scheduling all activities that it performs to run
    # in the background (via the scheduler)
    def run
      schedule_managers
    end

    # Initialize the Transport layer and run it in a background thread.
    def create_transport
      @transport = Transport.new config_file: @config['transport']
      @transport.open
      sleep(0.01) until @transport.is_open?
    end

    # Initialize all of the object managers defined by the configuration
    def create_managers
      # These options will apply to each manager by default. Some of these
      # options may be overridden by the configuration.
      general_manager_opts = { transports: [@transport] }
      @config['managers'].each do |name, manager_config|
        # For each source defined in the config, create a new Source instance
        # based on it's value
        source_objects = manager_config['sources'].inject([]) do |sources, (name, opts)|
          # The name of the source in the configuration should be its fully-
          # qualified class name. As such, it can be resolved to the class
          # object using `Object::const_get`. Errors are not rescued as there
          # is no valid way to recover from a misspelled source name.
          sources << Object.const_get(name.to_s).new(**opts.symbolize_keys)
        end
        # Determine the full configuration used to instantiate an ObjectManager
        this_manager_opts = general_manager_opts.merge(manager_config)
        this_manager_opts[:sources] = source_objects
        # Instantiate the ObjectManager and add it to the set of managers this
        # agency contains.
        @managers[name] = ObjectManager.new(**this_manager_opts.symbolize_keys)
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
    end
  end
end
