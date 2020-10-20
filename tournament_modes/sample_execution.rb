require_relative 'knockout'
require_relative 'round_robin'

teams = %w[A B C D E F G H].map{|t| Team.new("Team #{t}")}

rr = RoundRobin.new(teams)
print rr.schedule

rr.game_days.each{|d| d.games.each{|g| g.winner = [:team1, :team2].sample unless g.is_rest}}

print rr.scoreboard

leaderboard = rr.get_leaderboard
first = leaderboard[0]
first_places = leaderboard.select{|t| t.winrate == first.winrate}

last = leaderboard[-1]
last_places = leaderboard.select{|t| t.winrate == last.winrate}

case first_places.size
when 1
    second_places = leaderboard.select{|t| t.winrate == leaderboard[2].winrate}
    case second_places.size
    when 1
        print "Second Place: ".green
        print second_places.first.stats
    when 2
        print "Tie break for second place:\n"
        game = Game.new(second_places[0], second_places[1])
        print game.formatted
    else
        print "RR for second place\n"
        rr2 = RoundRobin.new(second_places)
        print rr2.schedule
        print rr2.scoreboard
    end
    print "First Place: ".green
    print first_places.first.stats
when 2
    print "Tie break for first place:\n"
    game = Game.new(first_places[0], first_places[1])
    print game.formatted
else
    print "RR for first 2 places\n"
    rr2 = RoundRobin.new(first_places)
    print rr2.schedule
    print rr2.scoreboard
end

case last_places.size
when 1
    last_places2 = leaderboard.select{|t| t.winrate == leaderboard[-2].winrate}
    case last_places2.size
    when 1
        last_places << last_places2[0]
    when 2
        print "Tie break for semi last place:\n"
        game = Game.new(last_places2[0], last_places2[1])
        print game.formatted
    else
        print "RR for semi last place\n"
        rr2 = RoundRobin.new(last_places2)
        print rr2.schedule
        print rr2.scoreboard
    end
when 2
    print "TEAMS ELIMINATED: ".red
    print last_places.each{|t| print t.name.purple + "\n"}
else
    print "RR for last place\n"
    rr2 = RoundRobin.new(first_places)
    print rr2.schedule
    print rr2.scoreboard
end