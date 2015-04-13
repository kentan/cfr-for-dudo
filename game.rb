require './human_player'
require './csr_player'
require './trainer'

class Game
  @@INITIAL_DICE_NUM = 2
  @@RANK_MAX = 6
  @@dice_history = []
  @@done = false
  def self.INITIAL_DICE_NUM
    @@INITIAL_DICE_NUM
  end
  def self.RANK_MAX
    @@RANK_MAX
  end
  def create_dice_set(num)
    dice = ""
    for i in 0..(num - 1)
      rank = Random.rand(Game.RANK_MAX) + 1
      dice += rank.to_s
    end
    return dice
  end
 
  def challenge(n, r, player1_dice_set, player2_dice_set,game=false)
#    puts "player0 dice are " + player1_dice_set
#    puts "player1 dice are " + player2_dice_set
    
    count = 0
    for i in 0..player1_dice_set.length
      if (player1_dice_set[i].to_i == r)
        count += 1
      end
    end

    for i in 0..player2_dice_set.length
      if (player2_dice_set[i].to_i == r)
        count += 1
      end
    end
    return n - count
  end

  def valid(next_hand,history,max)
    return true if next_hand == "dudo"
    return false unless next_hand.length == 2

    return true if history.length == 0
    return true if history[-2] == "r"

    n = next_hand[0].to_i
    r = next_hand[1].to_i

    return false if n > max
    return false if r > Game.RANK_MAX


    last_n = history[-2].to_i
    last_r = history[-1].to_i


    if n == last_n && r == last_r
      return false
    end

    if n >= last_n && r >= last_r
      return true
    end
    return false

  end

  def are_all_dice_nums_positive?(player_dice_nums)
    player_dice_nums.each do |num|
      if num <=0
        return false
      end
    end
    return true
  end

  def run(skip_train=true,num_of_train)
    unless skip_train
      puts "...now training..."
      trainer = Trainer.new(self)
      histories = trainer.train(num_of_train)
    end

    csr_player = CSRPlayer.new
    human_player = HumanPlayer.new

    play([human_player,csr_player], [@@INITIAL_DICE_NUM,@@INITIAL_DICE_NUM])
  end
  def show_result(player_dice_nums)
      for i in 0..player_dice_nums.length - 1
        print "player " + i.to_s + " has " + player_dice_nums[i].to_s + " dices\n"
        if player_dice_nums[i] <= 0
          print "player " + i.to_s + " has lost\n"
        end
      end
#    puts @@dice_history

  end
  def play(players,player_dice_nums)
    history = ""

    total_dice = player_dice_nums.reduce(:+)
    round = 0


    while are_all_dice_nums_positive?(player_dice_nums)
      round += 1
      player_dice = []
      puts "players dice:" + player_dice_nums.to_s

      player_dice_nums.each do |num|
        player_dice.push(create_dice_set(num))
      end

      puts "player1 dice are " + player_dice[0]
      @@dice_history.push(player_dice)
      dudo = false
      while !dudo
        for i in 0..(players.length - 1)
          next_hand = ""
          loop do
            puts "[" + players[i].class.to_s  + "] [" + history + "] input value>"
            next_hand = players[i].get_action(history)
            puts "[" + players[i].class.to_s  + "] [" + history + "] :" + next_hand 
            break if valid(next_hand,history,total_dice)
            puts "wrong value,input again>"
            break
          end

          if next_hand == "dudo"
            n = history[-2].to_i
            r = history[-1].to_i
            c = challenge(n, r, player_dice[0], player_dice[1],true)
            if(c == 0)
              puts "player " + i.to_s + " lost 1 die"
              player_dice_nums[i] -= 1
            else
              p = i == 0 ? players.length - 1 : i - 1
              puts "player " + p.to_s + " lost " + c.abs.to_s +  " dice"
              player_dice_nums[p] -= c.abs
            end
            history += ("r" + round.to_s)
            dudo = true
            break
          else
            history += next_hand.to_s
          end
        end
      end
    end

    show_result(player_dice_nums)
    puts "game done"
  end
end


skip_train = false
while true
	game = Game.new()
	game.run(skip_train,2)
	skip_train = true
end