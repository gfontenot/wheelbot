BOT_ROOT = File.join(File.dirname(__FILE__), "..")


# required for the bot to run
require "rubygems"
require "json"
require "twitter/json_stream"
require "httparty"
require "json"

# local classes required for the bot to run
require "#{BOT_ROOT}/lib/room"
require "#{BOT_ROOT}/lib/handlers"
require "#{BOT_ROOT}/lib/campsite"
require "#{BOT_ROOT}/lib/action"


module CampfireBot
  class Bot
    def initialize
      @config = YAML::load(File.read("#{BOT_ROOT}/config.yml"))
      
      load_handlers
      
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
        Kernel.const_get(action_class).new
      end
    
      @handlers =  Action.handlers
    
    end
    
    def run
      campsite = Campfire::Campsite.new(@config)
      
      @config["rooms"].each do |room_name|
        
        puts "Joining #{room_name}"
        room = Campfire::Room.new(room_name, @config, campsite)
        room.join
        Thread.new do
          begin
            room.listen(@handlers)
          rescue Exception => e
            trace = e.backtrace.join("\n")
            abort "Something went wrong! #{e.message}\n #{trace}"
          end
        end
      end  # Should be connected to all rooms by now
      
      puts "Listening"
      
      loop do
        # KEEP THE PROC ALIVE YO
        sleep 100
      end
    end
  end
end

def bot
  CampfireBot::Bot.new
end

bot.run