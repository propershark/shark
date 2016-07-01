module Shark
  module Storage
    extend self

    # The configuration used for storage. Defaults here can be overwritten
    # using `Storage::configure(options)`, where options are the replacement
    # configuration options.
    def configuration
      @configuration ||= {
        # Use the memory adapter to preference speed over scalability
        adapter: :memory
      }
    end

    # Overwrite values in the configuration hash with those given in `opts`.
    def configure opts
      configuration.merge!(opts)
    end


    # Return the single storage adapter instance
    def adapter
      @adapter ||= adapter_class.new configuration
    end

    # Return the class of the adapter to use for storage
    def adapter_class
      @@adapters[configuration[:adapter]]
    end

    # Register a new class that can be used as a storage adapter
    def register_adapter name, klass
      (@@adapters ||= {})[name] = klass
    end
  end
end


# Include packaged adapters
require_relative 'storage_adapters/abstract'
require_relative 'storage_adapters/memory'
