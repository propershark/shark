require 'yaml'

require 'rufus-scheduler'

require './object.rb'
require './objects/vehicle.rb'
require './objects/route.rb'
require './objects/station.rb'
require './object_manager.rb'
require './sources/doublemap.rb'
require './sources/doublemap/vehicle.rb'
require './sources/doublemap/route.rb'
require './sources/doublemap/station.rb'
require './transport.rb'


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
          symbolized_options = opts.each_with_object({}) do |(key, val), hash|
            hash[key.to_sym] = val
          end
          # The name of the source in the configuration should be its fully-
          # qualified class name. As such, it can be resolved to the class
          # object using `Object::const_get`. Errors are not rescued as there
          # is no valid way to recover from a misspelled source name.
          sources << Object.const_get(name.to_s).new(**symbolized_options)
        end
        # Determine the full configuration used to instantiate an ObjectManager
        this_manager_opts = general_manager_opts.merge(manager_config).each_with_object({}) do |(k, v), h|
          h[k.to_sym] = v
        end
        this_manager_opts[:sources] = source_objects
        # Instantiate the ObjectManager and add it to the set of managers this
        # agency contains.
        @managers[name] = ObjectManager.new(**this_manager_opts)
      end
    end

    # Register the managers with the scheduler to update at the interval
    # defined by their update_frequency.
    def schedule_managers
      @managers.each do |name, manager|
        @scheduler.every(manager.update_frequency){ manager.update }
      end
    end
  end
end
