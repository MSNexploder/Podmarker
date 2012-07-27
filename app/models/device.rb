class Device < ActiveRecord::Base
  attr_accessible :name, :caption, :device_type, :deleted

  belongs_to :user
  has_many :subscription_events
  has_many :episode_events

  def self.find_or_create(values)
    device = where(values).first
    
    # no device found - create new one
    if device.nil?
      ActiveSupport::Notifications.instrument('podmarker.devices.add', name: values[:name], user: user) do
        device = create values
      end
    end

    device
  end

  def subscription_count
    added, removed, timestamp = subscription_events.events_since_timestamp(0)
    added.count
  end

  private

  def self.user
    return nil if scope_attributes['user_id'].nil?
    User.find scope_attributes['user_id']
  end
end
