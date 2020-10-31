# Logic for a round robin or double round robin torunament, creates the matches and days
require_relative 'tournament_mode'

class RoundRobin < TournamentMode
  def initialize(teams, **opts)
    super(teams, **opts)
  end

  def name
    (@double ? "Double " : "") + self.class.name
  end

  def self.name
    "Round Robin"
  end

  # Counts the games played base on how many Game instances have attribute "winner" present
  def games_played
    game_days.inject(0) { |sum, day| sum + day.games_played }
  end

  # format the scoreboard
  def scoreboard
    result = ""
    group.leaderbord_list.each_with_index do |team, index|
      result += "#{index + 1}\t".bold + "-" + " #{team.name}".purple + " - W: " + "#{team.wins}".green + "\t| L: " + "#{team.losses}".red + "\t| Winrate: " + "#{"%.2f" % team.winrate}%\n".yellow
    end
    result
  end

  def add_tiebreak(game)
    tiebreak = GameDay.new(@game_days.last.day + 1, [game], name: "Tie-break") # ERRORE SUL NUMERO DEL GIORNO + AGGIUNGERE NOME CUSTOM
    @game_days << tiebreak

    define_singleton_method "day_#{tiebreak.day}" do
      tiebreak
    end
  end

  def build_tiebreaks
    leaderboard = get_leaderboard
    tiebreak_index = 1
    while leaderboard.size > 0
      places_teams = leaderboard.select { |t| t.winrate == leaderboard[-1].winrate }
      leaderboard -= places_teams
      case places_teams.size
      when 1
      when 2
        tiebreak = Game.new(places_teams[0], places_teams[1])
        game_day = GameDay.new(game_days.last.day, [tiebreak], name: "Tiebreak - Section #{tiebreak_index}")
        @game_days << game_day

        define_singleton_method "day_#{@game_days.last.day}" do
          game_day
        end
      else
        tiebreak = RoundRobin.new(places_teams, start_day: @game_days.last.day, name: "Tiebreak Round Robin - Section #{tiebreak_index}")
        @game_days += tiebreak.game_days

        tiebreak.game_days.each do |game_day|
          define_singleton_method "day_#{game_day.day}" do
            game_day
          end
        end
      end

      tiebreak_index += 1
    end
    self
  end

  private

  # Alg to create the tournament matches
  def calculate_tournament(**opts)
    @group.add_rest if (@group.size % 2) > 0

    tournament_days = if opts.dig(:double)
                        (@group.size - 1) * 2
                      else
                        (@group.size - 1)
                      end

    teams = @group.teams
    tournament_days.times do |day_index|
      day = day_index + (opts.dig(:start_day) || 0)
      games = teams.map.with_index { |t, i| Game.new(t, teams[teams.size - i - 1]) }.slice(0, teams.size / 2)
      first = teams[0]
      teams -= [first]
      teams.rotate!.unshift(first)

      @game_days << GameDay.new(day, games, name: opts.dig(:name) || '')

      define_singleton_method "day_#{day + 1}" do
        @game_days[day]
      end
    end
  end
end

# Logic for a round robin or double round robin torunament, creates the matches and days
require_relative 'tournament_mode'

class DoubleRoundRobin < RoundRobin
  private

  # Alg to create the tournament matches
  def calculate_tournament
    super(double: true)
  end
end