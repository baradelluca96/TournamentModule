# Represents a tournament, automates the creation of stats simplifies the management of a tournament, serves as entrypoint for all tournament modes
# Creates the methods for each team using name of the team (downcase -> remove spaces -> join "_")
# Creates the methods for each day using the number of the day, i.e. day_1, day_22 based on number of days in the tournament
class Tournament
  require_relative 'game_structure/team'
  MODES = %w[round_robin knockout]
  MODES.each { |mode| require_relative "tournament_modes/#{mode}" }

  attr_reader :group, :tournament_mode, :tournament_mode_instance, :days

  def initialize(teams, tournament_mode, **opts)
    @tournament_mode = tournament_mode
    start(**opts)
    create_team_methods(teams)
  end

  def schedule
    result = "Tournament - #{tournament_mode_instance.name}\n".bold
    result + tournament_mode_instance.formatted
  end

  def stats
    "Games played: #{tournament_mode_instance.games_played}\n" + tournament_mode_instance.get_scoreboard + "\n"
  end

  private

  def start(teams, **opts)
    @tournament_mode_instance = tournament_mode.new(teams, **opts)
    @group = @tournament_mode_instance.group

    @days = tournament_mode_instance.game_days.size
    @days.times do |i|
      define_singleton_method "day_#{i + 1}" do
        @tournament_mode_instance.send("day_#{i + 1}")
      end
    end
  end

  def create_team_methods
    group.teams.each do |team|
      define_singleton_method(team.name.downcase.split(" ").join("_")) { team } unless team == :rest
    end
  end
end