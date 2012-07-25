class Device < ActiveRecord::Base
  attr_accessible :name, :caption, :device_type, :deleted

  belongs_to :user
  has_many :subscription_events
  has_many :episode_events

  def subscription_count
    added, removed, timestamp = subscription_events.events_since_timestamp(0)
    added.count
  end
end
