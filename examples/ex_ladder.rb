require_relative '../tournament_modes/ladder'

teams_sorted = %w[A B C D].map { |t| Team.new("Team #{t}") }
ld = Ladder.new(teams_sorted)

print ld.schedule
ld.day_1.game_1.winner = :team1
ld.day_2.game_1.winner = :team2
ld.day_3.game_1.winner = :team1


print ld.schedule
