require_relative 'tournament'

teams = Team::Group.new(name: "Group Stage")
13.times do |index|
  teams << Team.new("team_#{index}")
end

t = Tournament.new(teams, DoubleRoundRobin)

# print t.team_1.stats
print t.schedule

t.days.times do |i|
  t.send("day_#{i+1}").games.each do |game|
    game.winner = [:team1, :team2].sample
  end
end

print t.team_1.stats
print t.stats