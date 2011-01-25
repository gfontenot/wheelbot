module CampfireBot
  class Action
    def initialize
      puts "test"
    end
  
    def hear (pattern, &action)
      @handlers[pattern] = action
    end
  end
end