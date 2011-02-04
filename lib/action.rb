module CampfireBot
  class Action
    @handlers = {}
    @@room = nil
    
    def initialize(room)
      @@room = room
    end
    
    def self.hear(pattern, &action)
      Action.handlers[pattern] = action
    end
    
    def self.speak msg
      @@room.speak msg
    end
    
    class << self    
      attr_reader :handlers
      attr_reader :room
    end
  end
end