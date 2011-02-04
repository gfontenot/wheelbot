class Vehicle_Stats < CampfireBot::Action
  
  hear /stats for ([0-9]{4})\s([a-z]+[\s|\-]?[a-z]+)\s(.+)/i do |matchdata|
    vehicle_stats_for(matchdata[1], matchdata[2], matchdata[3])
  end  
  
  # Look up vehicle stats through chrome
  def vehicle_stats_for(year, make, model)
    speak "Not written yet, asshole."
  end
end