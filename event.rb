module Shark
  class Event
    # The topic this event is being fired on
    attr_accessor :topic
    # The type of event being represented
    attr_accessor :type
    # The positional arguments for this event
    attr_accessor :args
    # The keyword arguments for this event
    attr_accessor :kwargs
    # The object that caused the creation of this event
    attr_accessor :originator

    def initialize topic:, type:, args:[], kwargs:{}, originator:
      @topic      = topic
      @type       = type
      @args       = args
      @kwargs     = kwargs
      @originator = originator
    end

    # Create a Hash representation of this event, attempting to convert all
    # `args` and `kwargs` to hash representations as well.
    def to_h
      {
        topic:      topic,
        type:       type,
        args:       args.map{ |arg| arg.respond_to?(:to_h) ? arg.to_h(nested: false) : arg },
        kwargs:     Hash[kwargs.map{|k, v| [k, v.respond_to?(:to_h) ? v.to_h(nested: false) : v] }],
        originator: originator
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
