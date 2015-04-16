class HumanPlayer
  def get_action(history,player_dice_nums)
    count = 2
    num = ""
    ARGF.each do |line|
      num = line.sub("\n","")
      break
    end

    return num
  end
end