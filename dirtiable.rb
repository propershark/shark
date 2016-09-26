module Shark
  module Dirtiable
    def self.included base
      base.extend ClassMethods
    end


    # Return the full set of attribute changes made since the last call to
    # `clean!`. The result will be a Hash keyed by attribute name, where the
    # values are [old_value, new_value] pairs.
    #
    # Example:
    #   object.name = 'John'
    #   object.name = 'Paul'
    #   object.changes => { name: [[nil, 'John'], ['John', 'Paul']] }
    def dirty_attributes
      @dirty_attributes ||= Hash.new{ |h, k| h[k] = [] }
    end
    alias_method :changes, :dirty_attributes

    # Consider the current state of the object as "clean". This clears the
    # changes hash, and causes `dirty?` to return false.
    def clean!
      dirty_attributes.clear
    end

    # Returns true if any attributes have changed since the `clean!` was called.
    def dirty?
      !dirty_attributes.empty?
    end

    # Record a change to an attribute's value.
    def dirty_attribute name, old_value, new_value
      dirty_attributes[name] << [old_value, new_value]
    end

    # Return true if the given attribute currently has a recorded change
    def has_changed? attribute
      !dirty_attributes[attribute].empty?
    end



    module ClassMethods
      def attr_accessor *names
        names.each do |name|
          attr_reader name
          attr_writer name
        end
      end

      def attr_writer *names
        names.each do |name|
          ivar_name = "@#{name}"
          define_method("#{name}=") do |new_value|
            old_value = instance_variable_get(ivar_name)
            instance_variable_set(ivar_name, new_value)

            # Only record a change if the new value is differs from the old value.
            if old_value != new_value
              dirty_attribute name, old_value, new_value
            end
          end
        end
      end
    end
  end
end
