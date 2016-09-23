module Shark
  class Production < Environment
    cli_name :production
    cli_name :prod

    def initialize options
      super
      puts "In the Production Environment"
    end
  end
end
