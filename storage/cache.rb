# A simplistic cache system for Storage adapters.
#
# Simply uses an in-memory Hash of limited size to provide efficient access to
# commonly used values.
#
# The size of the Hash is (currently) limited statically to 100 entries.
module Storage
  module Cache
    # The storage hash used to hold cache entries
    @storage = {}
    # The maximum number of entries to maintain in the cache
    @size_limit = 100

    # Add a new entry to the cache. If the cache is full, discard the oldest
    # entry.
    def store identifier, object
      @storage.shift if @storage.size >= @size_limit
      @storage[identifier] = object
    end

    # Retrieve the value of an entry in the cache. If the key does not exist in
    # the Hash, return nil.
    def fetch identifier
      @storage[identifier]
    end

    # Remove a single entry from the cache. Useful for maintaining older values
    # in the cache.
    def remove identifier
      @storage.delete(identifier)
    end

    # Remove all entries from the cache
    def clear
      @storage.empty
    end
  end
end
