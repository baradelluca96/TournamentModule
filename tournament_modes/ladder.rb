require_relative 'tournament_mode'
class Ladder < TournamentMode
  def calculate_tournament(**_)
    teams = @group.teams.reverse
    last_team = teams[0]
    (@group.size - 1).times do |i|
      new_game = Game.new(last_team, teams[i+1])
      @game_days << GameDay.new(i,[new_game])
      last_team = new_game
    end

    @game_days.size.times do |i|
      define_singleton_method "day_#{i + 1}" do
        @game_days[i]
      end
    end
  end
end