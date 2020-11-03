class TournamentMode
  require_relative '../game_structure/game_day'
  require_relative '../game_structure/team'

  attr_reader :game_days, :group
  def initialize(teams, **opts)
    @group = Team::Group.new(teams)
    @game_days = []
    calculate_tournament(**opts)
  end

   # Formats the whole tournament
  def formatted
    result = ""
    @game_days.each do |game_day|
      result += game_day.formatted
    end
    result
  end

  def get_leaderboard(**args)
    @group.leaderbord_list(**args)
  end

  def solve(&choose_winner)
    @game_days.each do |day|
      day.games.each do |game|
        yield(game) unless (game.is_rest || game.played?)
      end
    end
  end

  def solved?
    @game_days.all?{|day| day.games.all?{|game| game.played?}}
  end

  ATTRIBUTED_TEAM_RESOLVE = ->(game){
    if game.team1.ability > game.team2.ability
      game.winner = :team1
    elsif game.team2.ability > game.team1.ability
      game.winner = :team2
    else
      game.winner = [:team1, :team2].sample
    end
  }

  STANDARD_RESOLVE = ->(game){
    game.winner = [:team1, :team2].sample
  }

  alias_method :schedule, :formatted
end