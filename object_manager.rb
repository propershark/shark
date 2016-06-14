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
    # An array of Source objects that will be used to update the attributes of
    # each active object.
    attr_accessor :sources
    # The attribute of the objects used to index the object hashes. Must be an
    # an accessible attribute (the object responds to `send(<attribute>)`).
    attr_accessor :key

    # Instantiate a new ObjectManager
    def initialize primary_key
      @known_objects  = {}
      @active_objects = {}
      @sources        = []
      @key            = primary_key
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
      deactivate_all
      @sources.each do |source|
        source.refresh
        source.update self
      end
    end


    protected
      # Retrieve the key to be used for indexing objects from the given object.
      def pk_for object
        object.send(@key)
      end
  end
end
