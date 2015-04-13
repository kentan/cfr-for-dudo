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
      history,regret =line.split("*")
      node = Node.new
      node.set_all_regret_sum(regret)
      @histories[history] = node
    end
    
    puts "... data loaded..."
    @@loaded = true
  end

  def get_action(history)
    if @histories[history].nil?
       return "dudo"
    end

    return @histories[history].get_most_regretful_action
  end
end