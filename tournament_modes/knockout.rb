require_relative 'tournament_mode'

class Knockout < TournamentMode

  require_relative '../modules/observer'

  include Observer

  def initialize(*args)
    super(*args)
  end

  def check_teams_size
    raise "Cannot create knockout tournament with odd teams" if @group.size % 2 > 0
    exponential = Math.log2(@group.size)
    raise "Cannot create knockout tournament with a number of teams that is not an exponential of 2" unless exponential == exponential.round(0).to_f
  end

  def calculate_tournament
    raise NotImplementedError
  end

  def name
    self.class.name
  end

  # format the scoreboard
  def scoreboard
    result = ""
    group.leaderbord_list(sort: :by_win).each_with_index do |team, index|
      result += "#{index + 1}\t".bold + "-" + " #{team.name}".purple + " - W: " + "#{team.wins}".green + "\t| L: " + "#{team.losses}".red + "\t| Winrate: " + "#{"%.2f" % team.winrate}%\n".yellow
    end
    result
  end
end

class KnockoutSingle < Knockout
  def calculate_tournament(**opts)
    check_teams_size

    games = []

    (@group.size / 2).times do |i|
      games << Game.new(@group[i * 2], @group[i * 2 + 1])
    end

    @game_days << GameDay.new(0, games)

    while games.size > 1
      new_games = []
      (games.size / 2).times do |i|
        new_games << Game.new(games[i * 2], games[i * 2 + 1])
      end

      @game_days << GameDay.new(@game_days.last.day, new_games)
      games = new_games
    end

    @game_days.size.times do |i|
      define_singleton_method "day_#{i + 1}" do
        @game_days[i]
      end
    end
  end

  def self.name
    "Knock Out Single Elimination"
  end
end

class KnockoutDouble < Knockout
  def self.name
    "Knock Out Double Elimination"
  end

  def calculate_tournament(**opts)
    winners = @group[0]
    losers = @group[1]
    winner_games = []
    loser_games = []
    (winners.size / 2).times do |i|
      winner_games << Game.new(winners[i * 2], winners[i * 2 + 1])
    end

    (losers.size / 2).times do |i|
      loser_games << Game.new(losers[i * 2], losers[i * 2 + 1])
    end

    @game_days << GameDay.new(0, winner_games + loser_games)

    while winner_games.size > 1

      # Loser bracket day only
      new_games = []
      loser_games.size.times do |i|
        new_games << Game.new(winner_games[i].next_loser, loser_games[i])
      end

      @game_days << GameDay.new(@game_days.last.day, new_games, name: "Losers Bracket Day")
      loser_games = new_games

      # Regular day
      new_winner_games = []
      (winner_games.size / 2).times do |i|
        new_winner_games << Game.new(winner_games[i * 2], winner_games[i * 2 + 1])
      end
      winner_games = new_winner_games

      new_loser_games = []
      (loser_games.size / 2).times do |i|
        new_loser_games << Game.new(loser_games[i * 2], loser_games[i * 2 + 1])
      end
      loser_games = new_loser_games

      @game_days << GameDay.new(@game_days.last.day, winner_games + loser_games)
    end

    # Loser Bracket last day

    last_losers_game = Game.new(winner_games[0].next_loser, loser_games[0])
    @game_days << GameDay.new(@game_days.last.day, [last_losers_game], name: "Losers Bracket Day")

    # Maybe last regular day

    last_game = Game.new(winner_games[0], last_losers_game)
    @game_days << GameDay.new(@game_days.last.day, [last_game], name: "Final")

    @tiebreak = GameDay.new(@game_days.last.day, [Game.new(last_game.next_loser, last_game)], name: "Final Tiebreak")


    @game_days.size.times do |i|
      define_singleton_method "day_#{i + 1}" do
        @game_days[i]
      end
    end

    define_singleton_method "day_#{@tiebreak.day}" do
      @tiebreak
    end
  end

  def formatted
    result = super()
      result += @tiebreak&.formatted if @game_days.last.games.last.winner == @game_days.last.games.last.team2
    result
  end

  alias_method :schedule, :formatted
end

