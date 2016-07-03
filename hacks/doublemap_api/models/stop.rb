module DoubleMap
  class Model; end
  class Stop < Model
    # Return the identifying code for this stop.
    # TODO: don't actually do this.
    # This is a hack for http://citybus.doublemap.com, who include a stop
    # identifier in the name of each stop.
    def stop_code
      name[/BUS\w*|TEMP\w*/].chomp
    end
  end
end
