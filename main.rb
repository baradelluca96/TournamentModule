require_relative 'tournament'

# Worlds 2020 example - incorrect usage because forcing teams, only to show usage
teams = Team::Group.new(name: "Worlds 2020")
teams << Team.new("TES")
teams << Team.new("FNC")
teams << Team.new("SUN")
teams << Team.new("JDG")
teams << Team.new("GNG")
teams << Team.new("G2")
teams << Team.new("DRX")
teams << Team.new("DMW")

t = Tournament.new(teams, KnockoutSingle)

t.day_1.game_1.team1 = Team.new("DMW")
t.day_1.game_1.team2 = Team.new("DRX")
t.day_1.game_4.team1 = Team.new("TES")
t.day_1.game_4.team2 = Team.new("FNC")
t.day_1.game_3.team1 = Team.new("GEN")
t.day_1.game_3.team2 = Team.new("G2")
t.day_1.game_2.team1 = Team.new("SUN")
t.day_1.game_2.team2 = Team.new("JDG")
print t.schedule
t.day_1.game_1.winner = :team1
t.day_1.game_2.winner = :team1
print t.day_2.formatted # Updates the day2
print t.schedule

