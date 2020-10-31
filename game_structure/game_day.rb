# Represents a single game day numbered with @day, has many games
class GameDay
  require_relative '../modules/observer'
  require_relative '../modules/observable'

  include Observer
  include Observable

  require_relative 'game'
  attr_reader :day, :games, :name

  def initialize(index, games, name: '')
    @day = index + 1
    @games = games
    @name = name
    games.size.times do |i|
      @games[i].subscribe(self)
      define_singleton_method "game_#{i + 1}" do
        @games[i]
      end
    end
  end

  # Calculates how many games have a winner set, see Game class
  def games_played
    games.inject(0) { |sum, game| sum + (game.winner!=(:TBA) ? 1 : 0) }
  end

  def notify(obj, *args, &block)
    update(day, *args, &block)
  end

  def next_game_day
    raise NotImplementedError
  end

  # Formats game day
  def formatted
    result = "DAY #{@day}#{@name.empty? ? '' : (' - ' + name.light_blue.bold)}\n".bold
    @games.each do |game|
      result += " |\t" + game.formatted
    end
    result
  end
end
