class Node

  def initialize
    @regret_sum = {}
  end

  def get_most_regretful_action()

    max_action = 0
    max = -100
    @regret_sum.each do |action,regret|
      if regret > max
        max = regret
        max_action = action
      end
    end

    return max_action
  end

  def get_all_regret_sum
    @regret_sum
  end

  def set_all_regret_sum(data)
     data.tr!("{}","")
     data.split(",").each do |line|
       key,value = line.split("=>")
       key.tr!('" ',"")
       value = value.to_f
       @regret_sum[key] = value
     end
  end

  def get_regret_sum(action)
    @regret_sum[action]
  end
  def set_regret_sum(action,value)
    @regret_sum[action] = value;
  end


end