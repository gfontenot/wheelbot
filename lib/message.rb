module CampfireBot
  class Message
  
    def initialize(msg, room, handlers)
      @msg = msg
      @handlers = handlers
      perform_action(@msg)
    end   
    
    def perform_action(msg)
      @handlers.each do |pattern, action|
        if pattern.match(msg)
          action.call($~)
        end
      end
    end
  end
end