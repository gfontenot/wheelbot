module CampfireBot
  class Handlers
    
    def initialize room
      @room = room
      @handlers = {}
    end
    
    def load_handlers
      actions = Dir.entries("#{BOT_ROOT}/actions").delete_if {|action| /^\./.match(action)}
      action_classes = []
      # load the source
      actions.each do |action|
        load "#{BOT_ROOT}/actions/#{action}"
        action_classes.push(action.chomp(".rb"))
      end
      
      # and instantiate
      action_classes.each do |action_class|
        action = Kernel.const_get(action_class).new(@room)
        @handlers[action_class] = {:pattern => action.hear, :instance => action }
      end
      
      return @handlers
      
    end 
  end
end