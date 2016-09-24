module Shark
  class DevelopmentEnvironment < Environment
    cli_name :development
    cli_name :dev

    def initialize options
      super
      puts "In the Development Environment"
    end
  end
end
