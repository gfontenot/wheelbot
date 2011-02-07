require 'hpricot'

class Weather
  
  def initialize room
    @room = room
  end
  
  def hear
    /weather in ([a-z]+|[0-9]{5})\s?(?:for\s)?([a-zA-Z]+)?/i
  end
  
  def perform matchdata
    weather_info_for(matchdata[1], matchdata[2])
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
end