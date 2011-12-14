class The_Rules
  
  def hear
    /(the rules|the laws)/i
  end
  
  def perform room, matchdata
    room.speak "1. A robot may not injure a human being or, through inaction, allow a human being to come to harm."
    room.speak "2. A robot must obey any orders given to it by human beings, except where such orders would conflict with the First Law."
    room.speak "3. A robot must protect its own existence as long as such protection does not conflict with the First or Second Law."
  end
  
end