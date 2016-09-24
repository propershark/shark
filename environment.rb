require_relative 'hookable'

module Shark
  class Environment
    class << self
      def environments; @@environments ||= {}; end

      # Register an environment under the name used to reference it on the
      # command line.
      def cli_name name, type=self
        environments[name] = type
      end
    end


    include Configurable
    include Hookable


    # The full stack of middlewares to be installed for this session. This list
    # includes the Agency.
    def middleware_stack; @middleware_stack ||= []; end
    attr_writer :middleware_stack
    # The agency being run in this session.
    attr_accessor :agency
    # The runtime options passed in via the CLI.
    attr_accessor :options


    def initialize options
      @options = options
    end


    def configure
      before(:configure)
      Kernel.load(options[:config])
      after(:configure)
    end

    def load
      before(:load)
      @agency = Agency.new
      load_middlewares
      after(:load)
    end

    def finalize
      before(:finalize)
      stack_middlewares
      after(:finalize)
    end

    # Start running the agency. By default control will return to the caller
    # immediately, as the Agency is run in a separate thread. To make this
    # call block, specify `async: false`.
    def start async: true
      before(:start)
      agency.run
      after(:start)
      sleep unless async
    end


    protected
      # Insert a new Middleware instance into the stack. By default, it will be
      # added to the top of the stack, but specifying `after:` as the class name
      # of an existing Middleware type will insert the Middleware immediately
      # above that entry.
      #
      # Note that middlewares can not be added before the Agency.
      def insert_middleware klass, after: nil
        klass = Kernel.const_get(klass) if klass.is_a?(String)
        after = Kernel.const_get(after) if after.is_a?(String)

        middleware = klass.new
        # The insertion point is either the first instance of the specified type
        # in the middleware stack, or the last entry in the stack, if no type was
        # given.
        insertion_point = (middleware_stack.index{ |inst| inst.is_a?(after) } + 1) if after
        insertion_point ||= middleware_stack.size
        middleware_stack.insert(insertion_point, middleware)
      end

      # If `klass` is given, remove all middlewares of that type from the stack.
      # If `where` is given, remove all middlewares which cause the block to
      # return a truthy value.
      # If both are specified, no action will be taken.
      def remove_middleware klass = nil, where: nil
        if klass
          middleware_stack.delete_if{ |inst| inst.is_a?(klass) }
        elsif where
          middleware_stack.delete_if(&where)
        end
      end


    private
      # Create the middleware instances to be used in this session, and store
      # them in `middleware_stack`.
      def load_middlewares
        middleware_stack << agency
        # The middlewares to be used are determined by the agency configuration.
        agency.configuration.middlewares.each do |klass, args, kwargs, config|
          middleware_stack << klass.new(nil, *args, **kwargs, &config)
          klass.installed(self)
        end
        # Some Middlewares will use background threads to process work. By
        # sleeping for a short time between checks, those threads can work
        # concurrently instead of each one blocking serially.
        sleep(0.1) until middleware_stack.drop_while(&:ready?).empty?
      end

      # Apply the ordering of `middleware_stack` onto the Middleware instances.
      def stack_middlewares
        middleware_stack.each_cons(2){ |(previous, this)| previous.app = this }
        # Provide a blank Proc as the last element in the Middleware stack to
        # avoid errors where the last Middleware `fires` an event upward.
        middleware_stack.last.app = Proc.new{}
      end
  end
end
