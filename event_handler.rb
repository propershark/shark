module Shark
  class WebSocketEventHandler
    attr_accessor :namespace
    attr_accessor :transport

    def initialize namespace:, transport:
      @namespace = namespace
      @transport = transport
    end


    def on_activate object
      publish(:activate, object)
    end

    def on_deactivate object
      publish(:deactivate, object)
    end

    def on_update object
      publish(:update, object)
    end


    # Publish an event of the given type across the transport, with the given
    # object as a parameter.
    def publish event, object
      puts "Publishing an :#{event} event for #{object.class}##{object.identifier} to #{channel_name_for(object)}"
      @transport.publish(channel_name_for(object), [event, object.to_h])
    end

    private
      # Determine the name of the WAMP channel to which events about the given
      # object should be published.
      def channel_name_for object
        "#{namespace}.#{object.identifier}"
      end
  end
end
