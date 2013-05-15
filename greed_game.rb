require 'pry'

class DiceSet
  attr_reader :values

  def roll(number)
    @values = (1..number).map{1 + rand(6)}

  end

end


class Player
  attr_accessor :name, :total_points, :in_game, :dice_set

  def initialize(name)
    @name = name
    @total_points = 0
    @in_game = false
    @dice_set = DiceSet.new
  end

  def score(dice)
    return 0 if dice.empty? or dice.length > 5
    points = 0

    checker = lambda { |dice, num| dice.count(num) }

    num_ones = checker.call(dice,1)
    num_fives = checker.call(dice,5)

    case num_ones
      when 3,4,5
        points += 1000 + 100*(num_ones-3)

      when 1,2
        points += 100*(num_ones)
    end

    case num_fives
      when 3,4,5
        points += 500 + 50*(num_fives-3)

      when 1,2
        points += 50*(num_fives)
    end

    [2,3,4,6].each do |x|
      points += 100*x if dice.count(x) == 3
    end

    points
  end

  def get_roll_count()
    rolls = 0
    loop do
      puts
      print "Enter dice rolls for this turn [0-5] > "
      rolls = gets.chomp.to_i
      break if (0..5).include?(rolls)

      print "Do you want to take your turn or not? Enter a number between (0-5) > "
    end

    rolls
  end

  def take_turn()
    puts "You have entered the last turn of the game with score = #{total_points}" \
      if last_turn?(@total_points)

    set_of_numbers = dice_set.roll(get_roll_count)
    turn_score = score(set_of_numbers)
    puts "The set of numbers rolled >  #{set_of_numbers} w/ turn score = #{turn_score}"

    @in_game = score_above_min?(turn_score) unless @in_game
    @total_points += turn_score if @in_game

    self
  end

  def last_turn?(score)
    score >= 3000
  end


  def score_above_min?(score)
    score >= 300
  end

  end

class Game
  attr_accessor :player_list

  def initialize(number_of_players)
    @player_list = []
    number_of_players.times do
      player_name = get_player_name
      player_list << Player.new(player_name)
    end

  end

  def play()
    game_over = false
    begin
      player_list.each do |x|
        x.take_turn
        puts "Total points for #{x.name} > > > #{x.total_points}"

        game_over = x.last_turn?(x.total_points)
        break if game_over
      end
    end until game_over

    score_hash = player_list.reduce({}) { |h, x| h[x.name] = x.take_turn.total_points; h }

    score_hash.each {|k, v| puts "FINAL SCORE TALLY: #{k} > > > score #{v}"  }
  end

  private

  def get_player_name
    loop do
      print "What is your nickname?  "
      name = gets.chomp.to_s
      return name if name_valid?(name)
      puts "Your nickname is invalid, enter a different nickname"
    end
  end

  def name_valid?(name)
    return false if name.empty?

    player_name = player_list.map{|x| x.name}
    return false if player_name.include?(name)

    true
  end

end

game = Game.new(1)

game.play()