# When included this module improves the String class adding methods
# The methods added have the name of the keys in the color_scheme.rb file

# IMPORTANT: Remember to use print to make the changes effective

# Methods can be called multiple times on the same instance of string but
# only the first color and text format have effect;
module Kolorized
  COLOR_SCHEME = {
      dark_grey: 30,
      red: 91,
      green: 32,
      orange: 33,
      blue: 34,
      purple: 35,
      aqua: 36,
      yellow: 93,
      light_blue: 94,
      bright_blue: 96,
      light_grey: 37,
      light_purple: 95,
      bg_dark_grey: 100,
      bg_red: 101,
      bg_green: 102,
      bg_yellow: 103,
      bg_blue: 104,
      bg_purple: 105,
      bg_aqua: 106,
      bg_light_grey: 107,
    }
  class ::String
    Kolorized::COLOR_SCHEME.each do |name, value|
      define_method name do
        "\e[#{value}m#{self}\e[0m"
      end
    end

    # Custom color can be chosen, use it's 256 bit value
    # Reference: https://jonasjacek.github.io/colors/
    def color_256(value)
      "\e[38;5;#{value}m#{self}\e[0m"
    end

    # Text format
    def bold; add_format(1) end
    def italic; add_format(3) end
    def underline; add_format(4) end
    def reverse; add_format(7) end # Reverses the text color with the bg*

    def add_format(value)
      "\e[0;#{value}m#{self}\e[0m"
    end
  end
  # Usage examples
  # print "Example".blue
  # print "Another example".yellow.bold
  # print "Yet another example".color_256(124).italic
  # print "A strnage example".blue.red.underline.bold == print "A strnage example".blue.underline
end