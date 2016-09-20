require_relative 'agency'

module Shark
  class Runner
    # The Agency that will be managed by this Runner.
    attr_accessor :agency
    # A Hash of options for managing the runtime of the Agency. This hash must
    # at least include `config` and `environment`. Other values are optional.
    attr_accessor :options


    def initialize options
      @options = options
      # Load the configuration for this instance
      puts "| Loading configuration"
      Kernel.load(options[:config])
      # Create a new agency with that configuration
      puts "| Loading agency"
      load_agency
      # Perform any additional setup for the running environment
      puts "| Preparing environment"
      prepare_environment
      puts "| Ready"
    end


    # Perform any necessary setup for running in the requested environment
    def prepare_environment
      case options[:environment]
      when 'test'
        # Add the REPL at the requested point in the Middleware stack.
        insert_repl
      when 'production'
        # Production (as the default) does not require any preparation
      end
    end


    # Load an agency instance if one does not already exist.
    def load_agency
      @agency ||= Agency.new
    end

    # Start running the agency. Since `Agency#run` runs asynchronously, this
    # method will sleep to avoid prematurely interrupting operations. Set
    # `block: false` to override this behavior and return control immediately.
    def start block: true
      @agency.run
      sleep if block
    end


    private
      # Insert the REPL Middleware where requested to capture events at that
      # point in the Middleware stack.
      def insert_repl
        # Load the bootstrap to ensure events do not escape the environment
        require_relative 'test/bootstrap'
        # Load the REPL middleware that will be inserted into the stack
        require_relative 'test/repl'

        # Determine the full stack of Middlewares in use by the agency
        middleware_stack = [@agency]
        next_middleware = @agency.middleware
        # The last middleware in the stack will be a blank Proc
        until next_middleware.is_a?(Proc)
          middleware_stack << next_middleware
          next_middleware = next_middleware.app
        end

        repl = Test::REPL.new

        # Insert the middleware at the requested location
        if options[:insert_after]
          # Find the specified Middleware instance in the stack...
          insertion_point = middleware_stack.find{ |middleware| middleware.class.name == options[:insert_after] }
          # ...and add the REPL middleware at that point
          repl.app = insertion_point.app
          insertion_point.app = repl
        # Otherwise, insert it at the top of the stack
        else
          middleware_stack.last.app = repl
        end

        # Remove Transport middlewares from the stack
        transport_idx = middleware_stack.find_index{ |middleware| middleware.is_a?(Transport) }
        previous = middleware_stack[transport_idx-1]
        transport = previous.app
        previous.app = transport.app
      end
  end
end
