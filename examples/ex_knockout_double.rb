require_relative '../tournament_modes/knockout'

winners = %w[A B C D].map { |t| Team.new("Team #{t}") }
losers = %w[E F G H].map { |t| Team.new("Team #{t}") }

winners_brakcet = Team::Group.new(winners, name: "Winner Bracket")
losers_brakcet = Team::Group.new(losers, name: "Losers Bracket")



kod = KnockoutDouble.new([winners_brakcet, losers_brakcet])

print kod.schedule

kod.day_1.game_1.winner = :team1
kod.day_1.game_2.winner = :team2
kod.day_1.game_3.winner = :team2
kod.day_1.game_4.winner = :team1

kod.day_2.game_1.winner = :team2
kod.day_2.game_2.winner = :team2

kod.day_3.game_1.winner = :team1
kod.day_3.game_2.winner = :team1

kod.day_4.game_1.winner = :team2

kod.day_5.game_1.winner = :team2

kod.day_6.game_1.winner = :team1

print kod.schedule