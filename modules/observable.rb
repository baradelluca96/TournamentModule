# Defines a simple Observer - Observable pattern
module Observable
  require_relative 'observer'

  def subscribe(obs, &block)
    @observers ||= []
    @observers << {observer: obs, method: block || ->(obs) { }}
  end

  def unsubscribe(obs)
    @observers.delete(obs)
  end

  def update(*args)
    @observers&.each do |obs_hash|
      obs = obs_hash.dig(:observer)
      obs_hash.dig(:method).call obs
      obs.notify(self, *args)
    end
  end
end
