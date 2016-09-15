class Normalizer < Shark::Middleware
  class << self
    include Shark::Configurable
  end

  include Shark::Configurable
  inherit_configuration_from self

  def call event
    iterate_arguments(event) do |arg, key|
      handler_for(arg)&.call(arg)
    end
  end


  private
    def iterate_arguments event
      event.args.each{ |arg| yield arg, nil }
      event.kwargs.each{ |key, arg| yield arg, key }
    end

    def handler_for arg
      snaked_typename = arg.class.name.downcase.gsub(/\W+/, '_')
      handler_name = "on_#{snaked_typename}"
      # Return the configuration option (should be a proc) corresponding to the
      # type of the given argument
      configuration.send(handler_name) rescue nil
    end
end
