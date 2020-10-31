# Represents a single
class Team
  require_relative '../modules/kolorized'

  attr_reader :wins, :losses
  attr_accessor :name
  def initialize(name)
    @name = name
    @wins = 0
    @losses = 0
  end

  def win
    @wins += 1
    self
  end

  def unwin
    @wins -= 1
    self
  end

  def lose
    @losses += 1
    self
  end

  def unlose
    @losses -= 1
    self
  end

  def games
    @losses + @wins
  end

  def reset!
    @losses = 0
    @wins = 0
  end

  def winrate
    total = (wins + losses).to_f
    return 0.0 if total == 0.0
    (wins / total).to_f.round(4) * 100
  end

  def stats
    "#{name}".purple + " | " + "W: ".green + "#{wins}".green.bold + " - " + "L: ".red + "#{losses}".red.bold + " - " + "Winrate: ".orange + "#{"%.2f" % winrate}%\n".orange.bold
  end

  def to_h
    {
      is_rest: false,
      name: name,
      wins: wins,
      losses: losses,
    }
  end

  def <=>(other)
    if other == REST
      1
    elsif self == REST
      -1
    else
    other.winrate <=> winrate
    end
  end

  def ==(other)
    return false unless other
    if other == :TBA
      name == :TBA
    else
      name == other.name
    end
  end

  REST = self.new("REST")
  REST.instance_eval do
    def is_rest?; true; end
    def stats; ""; end
    def to_h
      {
        is_rest: true
      }
    end
    undef :win, :lose, :winrate
  end

  TBA = self.new(:TBA)
  TBA.instance_eval do
    def stats; ""; end
  end

  class Group
    include Enumerable
    attr_reader :group_type, :teams
    attr_accessor :name
    def initialize(elements = [], name: nil)
      is_teams_group = elements.all?{|t| t.class == Team}
      is_groups_group = elements.all?{|g| g.class == Group}
      raise "Se an array of Teams or Groups" unless is_teams_group || is_groups_group
      if is_teams_group
        class << self
          attr_reader :teams
        end
        @group_type = Team
        @teams = []
        elements.each {|t| add t}
        @name = name
      else
        class << self
          attr_reader :groups
        end
        @group_type = Group
        @groups = []
        elements.each{|g| add g}
      end
    end

    def each
      @teams.each {|t| yield t}
    end

    def check_type(element_type)
      raise "Need an element of type #{group_type}" if element_type != group_type
    end

    def [](val)
      case @group_type.name
      when "Team"
        @teams[val]
      when "Team::Group"
        @groups[val]
      end
    end


    def add(element)
      case element.class.name
      when "Team"
        check_type(Team)
        raise "Rest already added" if @teams.include?(REST) && element == REST
        names = @teams.map(&:name)
        raise "Duplicated name #{element.name}" if names.include?(element.name)
        @teams << element
        fix_max_name_length
      when "Team::Group"
        check_type(Group)
        names = @groups.map(&:name)
        raise "Duplicated name #{element.name}" if names.include?(element.name)
        @groups << element
      end
      self
    end

    alias_method :<<, :add

    def remove(element)
      case element.class.name
      when "Team"
        check_type Team
        @teams.delete(element)
      when "Team::Group"
        check_type Group
        @teams.delete(element)
      end
    end

    def stats
      case group_type.name
      when "Team"
        clean_teams = teams.dup
        clean_teams.delete(REST)
        "Group".bold + "#{name ? (" - " +  "#{name}".light_blue.bold) : ""}\n" + clean_teams.inject(""){|sum, team| sum + team.stats}
      when "Team::Group"
        "Macro group".bold + "#{name ? (" - " +  "#{name}".light_blue.bold) : ""}\n" + groups.inject(""){|sum, group| sum + group.stats}
      end
    end

    def leaderboard
      raise "Unavailable for Macro Group" if group_type == Group
      clean_teams = teams.dup
      clean_teams.delete(REST)
      i = 1
      "Group".bold + "#{name ? (" - " +  "#{name}".light_blue.bold) : ""}" + " - " + "Leaderboard\n".bold + clean_teams.sort.inject(""){|sum, team| sum = sum + "#{i} - "; i += 1; sum + team.stats}
    end


    def leaderbord_list(**args)
      raise "Unavailable for Macro Group" if group_type == Group
      clean_teams = teams.dup
      clean_teams.delete(REST)
      case args.dig(:sort)
      when :by_win
        clean_teams.sort_by{|t| t.wins}.reverse
      else
        clean_teams.sort
      end
    end


    def size
      raise "Unavailable for Macro Group" if group_type == Group
      @teams.size
    end

    def add_rest
      raise "Unavailable for Macro Group" if group_type == Group
      add REST
    end

    def remove_rest
      raise "Unavailable for Macro Group" if group_type == Group
      remove REST
    end

    def to_h
      case group_type.name
      when "Team"
        {
          name: name,
          teams: teams.map(&:to_h)
        }
      when "Team::Group"
        {
          name: name,
          groups: groups.map(&:to_h)
        }
      end
    end

    private
    # Used to align the name with the longest in group
    def fix_max_name_length
      max_length = @teams.sort_by{|team| team.name.length}.last.name.length
      @teams.map{|team| team.name = team.name.ljust(max_length, " ")}
    end
  end
end