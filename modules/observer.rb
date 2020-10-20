# Implements a simple Observer - Observable pattern
module Observer
  require_relative 'observable'

  def notify(*args, &block)
    raise "Method #notify not implemented in #{self.class}"
  end
end

