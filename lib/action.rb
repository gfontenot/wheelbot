module CampfireBot
  class Action
    attr_reader :handlers
    @handlers = {}
    # @room = nil
    
    def initialize(room)
      @room = room
    end
    
    
    class << self
      attr_reader :handlers
      attr_reader :room
      
      def speak msg
        @room.speak msg
      end
      
      def hear(pattern, &action)
        Action.handlers[pattern] = action
      end
    end
  end
end