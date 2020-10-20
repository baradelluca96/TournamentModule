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

  alias_method :schedule, :formatted
end