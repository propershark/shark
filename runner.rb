require_relative 'agency'
require_relative 'environment'
# Load all of the different environments to ensure that all possible names
# can be matched.
Dir['./environments/*.rb'].each{ |env| require env }

module Shark
  class Runner
    # A Hash of options for managing the runtime of the Agency. This hash must
    # at least include `config` and `environment`. Other values are optional.
    attr_accessor :options
    # The environment that this Runner will use for execution.
    attr_accessor :environment


    def initialize options
      @options = options
      create_environment
    end

    def start async: false
      environment.start async: async
    end


    private
      # Create and load Environment instance based on the `:environment` option
      # of this Runner.
      # If the given environment does not match any of the registered
      # environment names, raise an error.
      def create_environment env_name=options[:environment]
        klass = Environment.environments[env_name.to_sym]
        raise "Unknown environment `#{env_name}`." unless klass

        @environment = klass.new(options)
        environment.configure
        environment.load
        environment.finalize
      end
  end
end
