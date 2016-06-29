module Shark
  class ObjectManager
    # A hash of objects that this manager has dealt with at some point in it's
    # lifetime. This allows objects to be "deactivated" and "reactivated" at
    # any point while retaining all of their information, avoiding the need for
    # an external cache.
    attr_accessor :known_objects
    # A hash of objects that this manager is currently dealing with. Objects in
    # this hash will participate in all activities that this manager performs.
    # Objects not in this hash but in `known_objects` will not participate in
    # these activities.
    attr_accessor :active_objects
    # The frequency at which this manager should perform update cycles. That
    # is, how often the sources will be polled and events will be published.
    # Note that the owner of the manager is responsible for scheduling; this
    # attribute is simply here to match how frequencies are defined in the
    # configuration.
    attr_accessor :update_frequency
    # The agency that this manager belongs to. All events that this manager
    # creates will be pushed out to this agency.
    attr_accessor :agency
    # The namespace prefix used to isolate events that this manager publishes.
    # Will be concatenated with object identifiers to form a unique, fully-
    # qualified channel name.
    attr_accessor :namespace
    # An array of Source objects that will be used to update the attributes of
    # each active object.
    attr_accessor :sources


    # Instantiate a new ObjectManager
    def initialize update_frequency: '5s', agency:, namespace: '', sources: []
      @known_objects    = {}
      @active_objects   = {}
      @update_frequency = update_frequency
      @agency           = agency
      @namespace        = namespace
      @sources          = sources
    end

    # Add a new Source object to the list of sources.
    def add_source source
      @sources << source
    end

    # Remove a Source object from the list of sources.
    def remove_source source
      @sources.delete source
    end

    # Add an object to `active_objects`. If the object is not already in
    # `known_objects`, add it to that hash as well.
    def activate object
      pk = pk_for(object)
      @active_objects[pk] = object
      @known_objects[pk] = object
    end

    # Remove an object from `active_objects`, but keep its entry in
    # `known_objects`.
    def deactivate object
      @active_objects.delete pk_for(object)
    end

    # Remove all objects from `active_objects`. Entries in `known_objects` will
    # be preserved.
    def deactivate_all
      @active_objects.clear
    end

    # Completely remove an object from this manager. Its entries in both
    # `active_objects` and `known_objects` will be deleted.
    def remove object
      pk = pk_for(object)
      @active_objects.delete pk
      @known_objects.delete pk
    end

    # Return the object matching the key of the given object in the
    # `known_objects` hash, or nil if no match exists.
    def get key
      @known_objects[key] || nil
    end

    # Call the given block once for each active object, passing that object as
    # a parameter.
    def each &block
      @active_objects.each_value &block
    end

    # Call the given block once for each active object, passing the primary key
    # used to index that object and that object as parameters.
    def each_with_pk &block
      @active_objects.each &block
    end

    # Update the state of this manager by deactivating all objects, and polling
    # all sources to determine the new set of active objects.
    def update
      # Remember which objects were previously active
      previously_active = @active_objects.clone
      # Deactivate all objects to avoid keeping stale objects active
      deactivate_all
      # Poll all of the sources (in order) to update all objects and determine
      # the active set
      @sources.each do |source|
        source.refresh
        source.update self
      end
      # If any new objects were activated in this session, publish an
      # `activate` event
      (@active_objects.keys - previously_active.keys).each do |key|
        fire(:activate, @active_objects[key])
      end
      # Do the same for any objects that are no longer active
      (previously_active.keys - @active_objects.keys).each do |key|
        fire(:deactivate, previously_active[key])
      end
      # Publish update events for each currently active object
      @active_objects.each do |key, object|
        fire(:update, object)
      end
    end


    protected
      # Retrieve the key to be used for indexing objects from the given object.
      def pk_for object
        object.identifier
      end

      # Determine the fully-qualified name of the channel to which events about
      # the given object should be published.
      def channel_name_for object
        "#{@namespace}.#{object.identifier}"
      end

      # Pass an event to all of the transports defined for this manager, with
      # the object that the event is for passed as a parameter.
      def fire event_type, object
        agency.fire(event_type, channel_name_for(object), object.to_h)
      end
  end
end
