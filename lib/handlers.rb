module CampfireBot
  class Handlers
    def initialize (room, config)
      @config = config
      @room = room
      @handlers = {}
    end
    
    def hear (pattern, &action)
      @handlers[pattern] = action
    end
    
    def load_handlers
      
      hear /how/i do
        @room.speak "Better than you, meatbag"
      end
      
      hear /image me (.+)/i do |matchdata|
        @room.speak image_me(matchdata[1])
      end
      
      hear /weather in ([a-z]+|[0-9]{5})\s?(?:for\s)?([a-zA-Z]+)?/i do |matchdata|
        @room.speak weather_info_for(matchdata[1], matchdata[2])
      end
      
      hear /stats for ([0-9]{4})\s([a-z]+[\s|\-]?[a-z]+)\s(.+)/i do |matchdata|
        @room.speak vehicle_stats_for(matchdata[1], matchdata[2], matchdata[3])
      end
      
      hear /qc status/i do
        check_qc_status
      end
      
      return @handlers
    end
    
    # search Google Images for an image, and return a random result
    def image_me(query)
      base_url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&safe=active&q="
      url = "#{base_url}#{URI.encode(query)}"

      resp = Net::HTTP.get_response(URI.parse(url))
      result = JSON.parse(resp.body)

      images = result["responseData"]["results"]
      return images[rand(images.length)]["unescapedUrl"]
    end

    # search Google Weather for weather info about a place
    def weather_info_for(place, date)
      base_url = "http://www.google.com/ig/api?weather="
      url = "#{base_url}#{URI.encode(place)}"
      resp = Net::HTTP.get_response(URI.parse(url))
      begin
        forcast = ""
        unless date == nil
          
          requested_forcast = ""
          short_date = date[0, 3]
          doc, forecast_conditions = Hpricot::XML(resp.body), []

          if /tomorrow/i.match(date)
            requested_forcast = (doc/:forecast_conditions)[1].to_s #tomorrow's info
          else
            (doc/:forecast_conditions).each do |forecast|
              forcast_day = /<day_of_week data="(.+?)"/i.match(forecast.to_s)[1]
              if /#{short_date}/i.match(forcast_day)
                requested_forcast = forecast.to_s
              end
            end
          end

          temp_high = /<high data="(.+?)"/.match(requested_forcast)[1]
          temp_low = /<low data="(.+?)"/.match(requested_forcast)[1]
          condition = /<condition data="(.+?)"/.match(requested_forcast)[1]

          forcast = "#{condition}, High of #{temp_high}, Low of #{temp_low}"    
        else
          requested_conditions = /<current_conditions>(.+?)<\/current_conditions>/.match(resp.body)[1]
          # icon = /<icon data="(.+?)"/.match(current_conditions)[1]
          condition = /<condition data="(.+?)"/.match(requested_conditions)[1]
          humidity = /<humidity data="Humidity: (.+?)"/.match(requested_conditions)[1]
          temp = /<temp_f data="(.+?)"/.match(requested_conditions)[1]
          forcast = "#{condition}, #{temp} F, #{humidity} humidity"
        end
        
        @room.speak forcast
        
      rescue Exception => e
        return "Weather Error: #{e} (You may either misspelled the city, or tried searching for a date more than 3 days from now)"
      end
    end
    
    # Look up vehicle stats through chrome
    def vehicle_stats_for(year, make, model)
      return "Not written yet, asshole."
    end
    
    def check_qc_status
      base_dir = @config["qc"]["base_dir"]
      product_array = @config["qc"]["product_editor"]
      qc_array = @config["qc"]["qc_steps"]
      
      found_files = false
      
      product_array.each_pair do |product, editor|

        qc_dir = File.join(base_dir, product, "/Latest Batch/QC/")
        begin
          count = Dir.entries("#{qc_dir}0_Editor Review_#{editor}").delete_if {|file| /^\./.match(file)}.size
          unless count == 0
            @room.speak "#{editor} has #{count} #{product} ready to pass to QC"
            found_files = true
          end

          qc_array.each_pair do |dir, person|
            count = Dir.entries("#{qc_dir}#{dir}#{person}").delete_if {|file| /^\./.match(file)}.size


            unless count == 0
              @room.speak "#{person} has #{count} #{product} videos to QC"
              found_files = true
            end
          end
        rescue Exception => e
          puts e
        end
      end
      
      unless found_files
        @room.speak "QC status is clean"
      end
      
    end
  end
end