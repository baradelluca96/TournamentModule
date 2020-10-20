require_relative '../tournament_modes/round_robin'

teams = %w[A B C D E F G].map{|t| Team.new("Team #{t}")}

rr = RoundRobin.new(teams)

rr.singleton_methods.each do |m|
  rr.send(m).singleton_methods.each do |m2|
    game = rr.send(m).send(m2)
    if game.respond_to?(:winner)
      game.winner = [:team1, :team2].sample
    end
  end
end

rr.build_tiebreaks
print rr.scoreboard
print rr.schedule