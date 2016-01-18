module SourcedAttributes
  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    # Configure a new Source for a model.
    def sources_attributes_from source_name, **opts, &block
      @sources ||= {}
      @sources[source_name] ||= Source.create(source_name, opts, self)
      @sources[source_name].instance_eval(&block)
      @sources[source_name]
    end

    # Apply all Sources to the model. If `source_name` is specified, only apply
    # changes from that Source.
    def update_sourced_attributes source_name=nil
      if source_name
        @sources[source_name].apply
      else
        @sources.values.each(&:apply)
      end
    end
  end
end
