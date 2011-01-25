module CampfireBot
  class Action
    attr_reader :handlers
    @handlers = {}
    
    class << self
      attr_reader :handlers
      def hear(pattern, &action)
        Action.handlers[pattern] = action
      end
    end
  end
end