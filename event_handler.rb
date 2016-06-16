module Shark
  class WebSocketEventHandler
    attr_accessor :namespace
    attr_accessor :transport

    def initialize namespace:, transport:
      @namespace = namespace
      @transport = transport
    end

    def on_activate object
      puts "Publishing :activate event for #{object.class}##{object.code}"
      @transport.publish("#{namespace}.activate", [object])
    end

    def on_deactivate object
      puts "Publishing :deactivate event for #{object.class}##{object.code}"
      @transport.publish("#{namespace}.deactivate", [object])
    end

    def on_update object
      puts "Publishing :update event for #{object.class}##{object.code}"
      @transport.publish("#{namespace}.update", [object])
    end
  end
end
