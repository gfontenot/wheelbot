
# required for the bot to run
require "rubygems"
require 'hpricot'
require "json"
require "twitter/json_stream"
require "httparty"
require "json"

# local classes required for the bot to run
require "#{BOT_ROOT}/lib/room"
require "#{BOT_ROOT}/lib/message"
require "#{BOT_ROOT}/lib/handlers"
require "#{BOT_ROOT}/lib/campsite"


module CampfireBot
  class Bot
    def initialize
      @config = YAML::load(File.read("#{BOT_ROOT}/config.yml"))
    end
    
    def run
      campsite = Campfire::Campsite.new(@config)
      
      @config["rooms"].each do |room_name|
        
        puts "Joining #{room_name}"
        room = Campfire::Room.new(room_name, @config, campsite)
        room.join
        handlers = CampfireBot::Handlers.new(room, @config).load_handlers
        Thread.new do
          begin
            room.listen(handlers)
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