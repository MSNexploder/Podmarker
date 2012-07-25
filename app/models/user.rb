class User < ActiveRecord::Base
  attr_accessible :username, :password, :password_confirmation
  
  has_secure_password

  validates_presence_of :username
  validates_presence_of :password, :on => :create

  has_many :devices
  has_many :subscription_events, :through => :devices
  has_many :episode_events

  def self.authenticate(username, password)
    user = find_by_username(username)
    if user && user.authenticate(password)
      user
    else
      nil
    end
  end
end
