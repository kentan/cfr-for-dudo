require './node'
require 'yaml'
require 'zlib'


class Trial
  def initialize(dudo,action,player,history)
    @dudo = dudo
    @action = action
    @player = player
    @history = history
  end
  
  def dudo
    @dudo
  end 
  def action
    @action
  end

  def history
    @history
  end
  
  def player
    @player
  end
  
 
end
class Trainer

  def initialize(game)
    @game = game
    @histories = {}
  end

  def train(count=5)

    count.times do
	    num_player1 = Game.INITIAL_DICE_NUM
	    num_player2 = Game.INITIAL_DICE_NUM

	    player1_dice = @game.create_dice_set(num_player1)
	    player2_dice = @game.create_dice_set(num_player2)

	    max = num_player1 + num_player2
	    self.csr(1,0,player1_dice,player2_dice,max,false,"",true,0,1)
	    
    end
	
	puts "computed"
	data_to_be_recoded = ""
	@histories.each do |context,sub|
        data_to_be_recoded << "["
        data_to_be_recoded << context
        data_to_be_recoded << "]#"
        sub.each do |k,v|
            data_to_be_recoded << k
            data_to_be_recoded << "*"
            data_to_be_recoded << v.get_all_regret_sum.to_s
            data_to_be_recoded << "#"
        end
	end
	    
	compressed_data = Zlib::Deflate.deflate(data_to_be_recoded)
	File.binwrite("./train_data.dat",compressed_data)
	puts "trained"
	
  end

  def csr(n,r,player1_dice,player2_dice,max,dudo,history,first,round,stack)

    if(dudo)
      c = @game.challenge(n,r,player1_dice,player2_dice)

      num_player1 = player1_dice.length
      num_player2 = player2_dice.length
      if(first)
          if(c == 0)
              num_player1 -= 1
          else
              num_player2 -= c.abs
          end

      else
        if(c == 0)
            num_player2 -= 1
        else
            num_player1 -= c.abs
        end
        
        if(num_player2 <= 0)
            return -1
        end
        if(num_player1 <= 0)
            return 1
        end

        player1_dice = @game.create_dice_set(num_player1)
        player2_dice = @game.create_dice_set(num_player2)

        max = num_player1 + num_player2
#        return self.csr(1,1,player1_dice,player2_dice,max,false,history + "r" + (round+1).to_s,true,round+1,stack+1)
        return self.csr(1,1,player1_dice,player2_dice,max,false,"",true,round+1,stack+1)
     end
    else
      util = 0
      points = {}
      force_dudo = (n == max && r == Game.RANK_MAX)
      for i in n..max
        for j in r..Game.RANK_MAX
          if (i <= n && j <= r) && !force_dudo
            next
          end
          trials = [Trial.new(true,"dudo",first,history)]
          trials.push(Trial.new(false,i.to_s + j.to_s,!first,history + i.to_s + j.to_s)) unless force_dudo
          
          trials.each do |trial|
            
            count = self.csr(i, j, player1_dice, player2_dice, max, trial.dudo, trial.history,trial.player,round,stack+1)
            points[count] = trial.action
            prob = 1.0 / ((max - (n - 1)) * (Game.RANK_MAX - (j - 1)) * 2)
            util += count * prob
          end

        end
      end
      store_regret([player1_dice,player2_dice],history,points,util)
      return util
   end
  end

  def store_regret(players_dice,history,points,utility)
    node = ""
    context = ""
    players_dice.each do |v|
        context += v.length.to_s
    end
      
    if @histories.has_key?(context)
        sub_histories = @histories[context]
    else
        sub_histories = {}
        @histories[context] = sub_histories
    end
    
    if sub_histories.has_key?(history)
        node = sub_histories[history]
    else
        node = Node.new()
        sub_histories[history] = node
    end

    points.each do |point,action|
      regret = point - utility
      node.set_regret_sum(action,regret)
    end
  end
end
