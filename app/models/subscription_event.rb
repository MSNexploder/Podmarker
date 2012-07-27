class SubscriptionEvent < ActiveRecord::Base
  attr_accessible :url, :action, :timestamp

  belongs_to :device

  def self.added
    where action: 'added'
  end

  def self.removed
    where action: 'removed'
  end

  def self.sanitize_url(url)
    # TODO
    url
  end

  # returns [added_urls, removed_urls, timestamp] events
  def self.events_since_timestamp(since)
    new_timestamp = DateTime.now.to_i
    events = where { timestamp > since }.order :timestamp

    added_urls   = Set.new
    removed_urls = Set.new

    # last event to a given url wins
    events.each do |event|
      case event.action
        when 'added'
          added_urls.add      event.url
          removed_urls.delete event.url
        when 'removed'
          added_urls.delete event.url
          removed_urls.add  event.url
      end
    end

    [added_urls, removed_urls, new_timestamp]
  end

  # adds new subscription events
  def self.add_urls(urls)
    timestamp = DateTime.now.to_i
    urls.map do |url|
      ActiveSupport::Notifications.instrument('podmarker.subscriptions.add', url: url, device: device) do
        create action: 'added', timestamp: timestamp, url: url
      end
    end
  end

  # remove existing subscription events
  def self.remove_urls(urls)
    timestamp = DateTime.now.to_i
    urls.map do |url|
      ActiveSupport::Notifications.instrument('podmarker.subscriptions.remove', url: url, device: device) do
        create action: 'removed', timestamp: timestamp, url: url
      end
    end
  end

  private

  def self.device
    return nil if scope_attributes['device_id'].nil?
    Device.find scope_attributes['device_id']
  end
end
