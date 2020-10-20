# Represents a single game, holds two teams and a winner if the game has been played
class Game
  require_relative '../modules/observable'

  require_relative 'team'
  require_relative 'game_day'

  include Observable

  attr_reader :winner, :loser, :is_rest
  attr_accessor :game_day
  attr_writer :team1, :team2

  def initialize(team1, team2)
    if team1 == Team::REST || team2 == Team::REST
      @is_rest = true

      class << self
        undef :winner=, :delete_result, :team1,
          :team2, :team1=, :team2=, :winner, :loser
      end
    end

    @team1 = team1
    @team2 = team2
    @winner = :TBA # default :TBA, game not played yet
    @loser = :TBA
  end

  # Formats a string representing the game depending on the state (played or not)
  def formatted
    if is_rest
      rest_formatted
    else
      case @winner
      when :TBA
        standard_formatted
      when team1
        "#{team1.name} W".green + ' vs ' + " L #{team2.name}\n".red
      when team2
        "#{team1.name} L".red + ' vs ' + " W #{team2.name}\n".green
      else
        # is a game
        @team1 = @team1.winner
        @team2 = @team2.winner
        formatted
      end
    end
  end

  def next_loser
    @reversed_game = Game.new(@team2, @team1)
  end

  def team1
    if @team1.is_a? Team
      @team1
    else
      # is game
      val = @team1.winner
      if @team1.is_a? Game
        @team1 = @team1.winner unless @team1.winner == :TBA
      end
      val
    end
  end

  def team2
    if @team2.is_a? Team
      @team2
    else
      val = @team2.winner
      if @team2.is_a? Team
        @team2 = @team2.winner unless @team2.winner == :TBA
      end
      val
    end
  end

  # Sets the winner for this match
  def winner=(value)
    return if is_rest
    raise 'Winner already set' if @winner != :TBA

    if value.class == Symbol
      if value == :team1
        @reversed_game&.winner = :team1
        team1.win
        team2.lose
        @loser = team2
        @winner = team1
      elsif value == :team2
        @reversed_game&.winner = :team2
        team2.win
        team1.lose
        @loser = team1
        @winner = team2
      else
        raise 'Use :team_1 or :team_2 to set the winner'
      end
    elsif value.class == Team
      raise "Can't set team by name if reversed game present" if @reversed_game
      @winner = value
      @reversed_game&.winner = value
      value.win
      @loser = if team1 == value
                 team2.lose
                 team1
               else
                 team1.lose
                 team2
               end
    end
    update :result_set
    true
  end

  def delete_result
    if @winner
      @winner.unwin
      @loser.unlose
    end
    @winner = nil
    @loser = nil
    update :result_deleted
    true
  end

  def to_h
    {
      team1: team1.to_h,
      team2: team2.to_h,
      winner: winner.to_h
    }
  end

  private

  def rest_formatted
    if @team1 == Team::REST
      @team2.name.purple + " - REST\n".aqua
    elsif @team2 == Team::REST
      @team1.name.purple + " - REST\n".aqua
    end
  end

  def standard_formatted
    result = ''
    result += if team1 == :TBA
                'TBA'.orange
              else
                team1.name.purple
              end
    result += ' vs '
    result += if team2 == :TBA
                "TBA\n".orange
              else
                "#{team2.name}\n".purple
              end
    result
  end
end
