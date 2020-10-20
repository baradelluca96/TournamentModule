require_relative '../tournament_modes/knockout'

teams = %w[A B C D E F G H].map { |t| Team.new("Team #{t}") }

ko = KnockoutSingle.new(teams)

# print ko.schedule

# ko.game_days.size.times do |i|
#   day = ko.send("day_#{i+1}")
#   day.games.size.times do |j|
#     day.send("game_#{j+1}").winner = %i[team1 team2].sample
#   end
# end

ko.day_1.game_1.winner = :team1
ko.day_1.game_2.winner = :team1

ko.day_1.game_3.winner = :team2
ko.day_1.game_4.winner = :team1

ko.day_2.game_1.winner = :team1
ko.day_2.game_2.winner = :team2

ko.day_3.game_1.winner = :team1

print ko.schedule
print ko.scoreboard