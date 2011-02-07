class Vehicle_Stats
  
  def initialize room
    @room = room
  end
  
  def hear
    /stats for ([0-9]{4})\s([a-z]+[\s|\-]?[a-z]+)\s(.+)/i
  end
  
  def perform matchdata
    vehicle_stats_for(matchdata[1], matchdata[2], matchdata[3])
  end
  
  def desc_short
    "stats for YEAR MAKE MODEL"
  end
  
  def desc_long
    "Search Chrome for vehicle provided, and return a list of stats. IN DEVELOPMENT"
  end  
  
  # Look up vehicle stats through chrome
  def vehicle_stats_for(year, make, model)
    @room.speak "Not written yet, asshole."
  end
end