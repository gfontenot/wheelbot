module CampfireBot
  class Action
    attr_reader :handlers
    @handlers = {}
    # @room = nil
    
    class << self
      attr_reader :handlers
      attr_reader :room
      
      
      def initialize(room)
        @room = room
      end
      
      
      def speak msg
        @room.speak msg
      end
      
      def hear(pattern, &action)
        Action.handlers[pattern] = action
      end
    end
  end
end