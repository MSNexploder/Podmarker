class CreateInitialModels < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest

      t.timestamps
    end

    add_index :users, :username

    create_table :devices do |t|
      t.references :user
      t.string :name
      t.string :caption
      t.string :device_type
      t.boolean :deleted

      t.timestamps
    end

    add_index :devices, :user_id
    add_index :devices, :name

    create_table :episode_events do |t|
      t.references :user
      t.references :device
      t.string :podcast
      t.string :url
      t.string :action
      t.datetime :performed_at
      t.integer :timestamp
      t.integer :started
      t.integer :position
      t.integer :total

      t.timestamps
    end

    add_index :episode_events, :user_id
    add_index :episode_events, :device_id
    add_index :episode_events, :podcast
    add_index :episode_events, :url

    create_table :subscription_events do |t|
      t.references :device
      t.string :url
      t.string :action
      t.integer :timestamp

      t.timestamps
    end

    add_index :subscription_events, :device_id
    add_index :subscription_events, :timestamp
  end
end
