require_relative 'tournament'
group = Team::Group.new(name: "Winner Bracket")
8.times do |index|
  group << Team.new("team_#{index}")
end
t = Tournament.new(group, KnockoutSingle)
t.day_1.game_1.winner = :team2
t.day_1.game_2.winner = :team1
print t.day_2.formatted
print t.schedule