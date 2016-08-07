require 'set'

require_relative 'configurable/object_manager_configuration'

module Shark
  class ObjectManager
    class << self
      include Configurable
      use_configuration_type ObjectManagerConfiguration
    end
    include Configurable
    inherit_configuration_from self


    # A human name for this manager. Not used internally, but useful for
    # reflecting on instances within an Agency.
    attr_accessor :name
    # A hash of objects that this manager is currently dealing with. Objects in
    # this hash will participate in all activities that this manager performs.
    # Objects not in this hash but in `known_objects` will not participate in
    # these activities.
    attr_accessor :active_objects
    # The agency that this manager belongs to. All events that this manager
    # creates will be pushed out to this agency.
    attr_accessor :agency
    # A reference to the storage adapter being used. This is generally a global
    # value, but having a local reference to it simplifies code lines, and
    # allows for overrides if necessary.
    attr_accessor :storage
    # The frequency at which this manager should perform update cycles. That
    # is, how often the sources will be polled and events will be published.
    # Note that the owner of the manager is responsible for scheduling; this
    # attribute is simply here to match how frequencies are defined in the
    # configuration.
    attr_accessor :update_frequency
    # The namespace prefix used to isolate events that this manager publishes.
    # Will be concatenated with object identifiers to form a unique, fully-
    # qualified channel name.
    attr_accessor :namespace
    # An array of Source objects that will be used to update the attributes of
    # each active object.
    attr_accessor :sources


    # Instantiate a new ObjectManager, first calling the configurator to apply
    # any instance-level configurations, then applying those configurations to
    # attributes of this class.
    def initialize name, agency, &configurator
      # Apply the configurator's options
      configure &configurator
      @name             = name
      @agency           = agency
      @active_objects   = Set.new
      # TODO: Include `storage` in the configuration
      @storage          = Storage.adapter
      @klass            = configuration.object_type
      @update_frequency = configuration.update_frequency
      @namespace        = configuration.namespace
      # Create the source instances by lookup based on the given name, and the
      # object_type specified for thie ObjectManager. Additionally, apply any
      # additional configuration that was given for each Source.
      @sources          = configuration.sources.map do |name, config|
        Source.create(name, @klass, config)
      end
    end

    # Add an object to `active_objects`. If the object is not already in
    # `storage`, add it there as well.
    def activate object
      id = identifier_for(object)
      @active_objects << id
      @storage.create(id, object)
    end

    # Remove an object from `active_objects`, but keep its entry in
    # `storage`.
    def deactivate object
      @active_objects.delete identifier_for(object)
    end

    # Remove all objects from `active_objects`. Entries in `storage` will be
    # preserved.
    def deactivate_all
      @active_objects.clear
    end

    # Completely remove an object from this manager. Its entries in both
    # `active_objects` and `storage` will be deleted.
    def remove object
      pk = pk_for(object)
      full_identifier = identifier_for(object)
      @active_objects.delete pk
      @storage.remove(full_identifier)
    end

    # Return the object matching the key of the given object in `@storage`, or
    # nil if no match exists.
    def find key
      @storage.find("#{@namespace}.#{key}") || nil
    end

    # Return the object matching the key of the given object in the
    # `known_objects` hash, or create a new instance if no match exists.
    def find_or_new key
      find(key) || @klass.new
    end

    # Call the given block once for each active object, passing that object as
    # a parameter.
    def each &block
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
      (@active_objects - previously_active).each do |key|
        fire(:activate, @storage.find(key))
      end
      # Do the same for any objects that are no longer active
      (previously_active - @active_objects).each do |key|
        fire(:deactivate, @storage.find(key))
      end
      # Publish update events for each currently active object
      @active_objects.each do |key|
        fire(:update, @storage.find(key))
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
      alias_method :identifier_for, :channel_name_for

      # Create an event to be sent out from the agency. The event originating
      # here consists of:
      # - event_type: the type of event being sent.
      # - channel: the namespace the event should be broadcast in.
      # - args: a single argument, the object the event relates to.
      # - originator: who is responsible for initiating the event.
      def fire event_type, object
        meta = { originator: channel_name_for(object) }
        agency.call(event_type, channel_name_for(object), object, meta)
      end
  end
end
