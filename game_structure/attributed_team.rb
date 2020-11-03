require_relative 'team' 
class AttributedTeam < Team
    def initialize(name, initial_value = (rand(8) + 2))
        @initial_value = initial_value.to_f
        @ability = initial_value.to_f
        @last_ability = nil
        super name
    end

    attr_reader :last_ability, :initial_ability

    def ability
        plus_minus_rand(@ability, 2)
    end

    def base_ability
        @ability
    end

    def win
        @last_ability = @ability
        @ability = win_improve @ability
        super
    end

    def unwin
        raise "Can't unwin, last ability is nil" unless @last_ability
        @ability = @last_ability
        @last_ability = nil
        super
    end

    def unlose
        raise "Can't unlose, last ability is nil" unless @last_ability
        @ability = @last_ability
        @last_ability = nil
        super
    end

    def reset!
        @ability = @initial_value
        @last_ability = nil
        super
    end

    def lose
        @last_ability = @ability
        @ability = lose_improve @ability
        super
    end

    def improvement_percentage
        (@ability - @initial_value) / @initial_value
    end

    def stats
        formatted_percentage = "%.2f" % (improvement_percentage * 100)
        super(:block_new_line) + " | Improvement: " + "#{(improvement_percentage >= 0) ? (formatted_percentage + "%\n").green : (formatted_percentage + "%\n").red}"
    end

    private
    def plus_minus_rand(base, modifier)
        (base - modifier) + (rand * modifier * 2)
    end

    def win_improve(score)
        if rand >= WIN_IMPROVE_CHANCE
            score + rand * WIN_IMPROVE_POSITIVE
        else
            score - rand * WIN_IMPROVE_NEGATIVE
        end
    end

    def lose_improve(score)
        if rand >= LOSE_IMPROVE_CHANCE
            score + rand * LOSE_IMPROVE_POSITIVE
        else
            score - rand * LOSE_IMPROVE_NEGATIVE
        end
    end

    WIN_IMPROVE_CHANCE ||= 0.65
    WIN_IMPROVE_POSITIVE ||= 0.4
    WIN_IMPROVE_NEGATIVE ||= 0.15

    LOSE_IMPROVE_CHANCE ||= 0.5
    LOSE_IMPROVE_POSITIVE ||= 0.7
    LOSE_IMPROVE_NEGATIVE ||= 0.35
end