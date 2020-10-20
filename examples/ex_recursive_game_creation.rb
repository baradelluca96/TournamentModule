require_relative '../game_structure/game_day'

teams = %w[A B C D E F G H].map { |t| Team.new("Team #{t}") }

games = []
(teams.size / 2).times { |i| games << Game.new(teams[i * 2], teams[i * 2 + 1]) }

gd = GameDay.new(0, games)

current_game_day = gd
while (current_game_day.games.size > 1) do
  games = current_game_day.games
  new_games = []
  (games.size / 2).times do |i|
    new_games << Game.new(games[i * 2], games[i * 2 + 1])
  end

  new_day = GameDay.new(current_game_day.day, new_games)

  current_game_day.next_game_day = new_day
  current_game_day = new_day
end