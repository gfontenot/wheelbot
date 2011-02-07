module Campfire  
  class Room
    attr_reader :room_id
    
    include HTTParty
    headers     'Content-Type' => 'application/json'
  
    def initialize(room_name, config, campsite)
      @campsite = campsite
      @name = room_name
      @room_id = campsite.room_id_from_name(room_name)
      @token = config["api_key"]
      @config = config
      
      Room.base_uri    "https://#{config['subdomain']}.campfirenow.com"
      Room.basic_auth  "#{@token}", "x"
    end
    
    def to_s
      return @name
    end
    
    def join
      post 'join'
    end
  
    def speak(message)
      send_message message
    end
  
    def listen(handlers)
      options = {
        :path => "/room/#{@room_id}/live.json",
        :host => 'streaming.campfirenow.com',
        :auth => "#{@token}:x"
      }
    
      EventMachine::run do
        stream = Twitter::JSONStream.connect(options)

        stream.each_item do |item|
          msg = JSON.parse(item)
          unless msg["user_id"] == @campsite.me["id"]
            if /^#{@config["bot_name"]}:/i.match(msg["body"])
              perform_action(msg["body"], handlers)
            end
          end
        end

        stream.on_error do |message|
          puts "ERROR:#{message.inspect}"
        end

        stream.on_max_reconnects do |timeout, retries|
          puts "Tried #{retries} times to connect."
          exit
        end
      end
    end
  
    def perform_action(msg, handlers)
      
      if /help/i.match(msg) # Print out the help messages for all the active plugins
        speak "I listen for the following:"
        handlers.each_pair do |key, action|
          if action[:instance].desc_long
            action_help = "#{action[:instance].desc_short}: #{action[:instance].desc_long}"
          else
            action_help = action[:instance].desc_short
          end
          speak action_help
        end
      else
        handlers.each_pair do |key, action|
          pattern = action[:pattern]
          if pattern.match(msg)
            action[:instance].perform ($~)
          end
        end
      end
    end
  
    private
  
    def send_message(message, type = 'Textmessage')
      post 'speak', :body => {:message => {:body => message, :type => type}}.to_json
    end
  
    def post(action, options = {})
      Room.post room_url_for(action), options
    end
  
    def room_url_for(action)
      "/room/#{room_id}/#{action}.json"
    end
  end
end