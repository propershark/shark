module Shark
  class ObjectManagerConfiguration < Configuration
    # Specify a source to include in an ObjectManager. Each ObjectManager will
    # get its own instance of the Source.
    # If `config` is given (as a Hash of options), it will be applied on top of
    # the class configuration for that Source.
    def sources; @sources ||= []; end
    def source_from name, config={}
      sources << [name, config]
    end
  end
end
