require 'yaml'
require 'zlib'


class CSRPlayer
  @@loaded = false
  def initialize()
    @histories = {}
    load_data unless @@loaded

  end

  def load_data
    puts "... data loading..."
    count = 0
    compressed = ""
    
    compressed = File.binread("./train_data.dat")

    
    decompressed_data = Zlib::Inflate.inflate(compressed)

    decompressed_data.split("#").each do |line|
      if line =~ /^\[.*\]$/
          context = line
          next
      end
      
      if @histories.has_key?(context)
         sub_histories =  @histories[context]
      else
         sub_histories = {}
         @histories[context] = sub_histories
      end
      history,regret =line.split("*")
      node = Node.new
      node.set_all_regret_sum(context,regret)
      
      sub_histories[history] = node
      @histories[context] = sub_histories

#      @histories[history] = node
    end
    
    puts "... data loaded..."
    @@loaded = true
  end

  def get_action(history,player_dice_nums)
    if @histories[history].nil?
       return "dudo"
    end
    
    context = player_dice_num.reduce(:+).to_s
    return @histories[context][history].get_most_regretful_action
#    return @histories[history].get_most_regretful_action
  end
end