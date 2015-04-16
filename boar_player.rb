

class BoarPlayer
  def get_action(history,player_dice_nums)
      count = 2
      return "11" if history==""
      n = history[-2]
      r = history[-1]
      
      return "11" if n =="r"
      
      n = n.to_i
      r = r.to_i
      total = player_dice_nums.reduce(:+)
      return n.to_s + (r + 1).to_s if(r < Game.RANK_MAX) 
      return (n + 1).to_s + r if(n < total)
      
      return "dudo"
  
  end
end