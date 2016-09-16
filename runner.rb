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
      puts options
      prepare_environment
    end


    # Perform any necessary setup for running in the requested environment
    def prepare_environment
      case options[:environment]
      when 'test'
        insert_repl
      when 'production'
        # Production (as the default) does not require any prepare
      end
    end


    # Load an agency instance if one does not already exist.
    def load
      # Ensure that the requested configuration is the most recently loaded
      # before creating the Agency instance.
      @agency ||= begin
        Kernel.load(options[:config])
        Agency.new
      end
      self
    end

    # Start running the agency. Since `Agency#run` runs asynchronously, this
    # method will sleep to avoid prematurely interrupting operations. Set
    # `block: false` to override this behavior and return control immediately.
    def start block: true
      puts "Starting"
      @agency.run
      sleep if block
    end

    private
      # Insert the REPL Middleware where requested to capture events at that
      # point in the Middleware stack.
      def insert_repl
      end
  end
end
