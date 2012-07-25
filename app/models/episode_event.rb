class EpisodeEvent < ActiveRecord::Base
  attr_accessible :podcast, :url, :action, :performed_at, :timestamp, :started, :position, :total

  belongs_to :user
  belongs_to :device

  def self.sanitize(episode_data)
    # TODO
    episode_data
  end

  # adds new episode events
  def self.add_events(data)
    timestamp = DateTime.now.to_i
    data.map do |event_data|
      create do |event|
        event.podcast      = event_data[:podcast]
        event.url          = event_data[:url]
        event.action       = event_data[:action]
        event.performed_at = event_data[:timestamp]
        event.started      = event_data[:started]
        event.position     = event_data[:position]
        event.total        = event_data[:total]
        event.timestamp    = timestamp
        event.device = event.user.devices.find_by_name(event_data[:device]) if event_data.has_key? :device
      end
    end
  end

  # returns [events, timestamp] events
  def self.events_since_timestamp(since, options = {})
    new_timestamp = DateTime.now.to_i
    events = where { timestamp > since }.order :timestamp
    events = events.where(podcast: options[:podcast]) if options[:podcast] # options[:podcast] can be present but nil

    result = events
    if options[:aggregated]
      events_hash = {}
      events.each do |event|
        events_hash[event.url] = event
      end
      result = events_hash.values
    end

    [result, new_timestamp]
  end
end
