module Api
  module V2
    class EpisodesController < ApplicationController
      before_filter :authenticate
      before_filter :fix_params_parsing, only: ['show', 'update']

# [
#   {
#    "podcast": "http://example.com/feed.rss",
#    "episode": "http://example.com/files/s01e20.mp3",
#    "device": "gpodder_abcdef123",
#    "action": "download",
#    "timestamp": "2009-12-12T09:00:00"
#   },
#   {
#    "podcast": "http://example.org/podcast.php",
#    "episode": "http://ftp.example.org/foo.ogg",
#    "action": "play",
#    "started": 15,
#    "position": 120,
#    "total":  500
#   }
#  ]

# {"actions": (list of episode actions here - see above for details),
#     "timestamp": 12345}

# todo aggregated

      def show
        podcast = params[:podcast]
        device_name = params[:device]
        since = params[:since] || 0
        aggregated = params[:aggregated].try(:to_bool) || false

        # use device if given - fallback to current_user
        device = current_user.devices.find_by_name device_name
        scope = device ? device : current_user

        actions, timestamp = scope.episode_events.events_since_timestamp(since, podcast: podcast, aggregated: aggregated)

        response = {
          timestamp: timestamp,
          actions: actions
        }

        respond_to do |format|
          format.json { render json: response }
        end
      end

      def update
        episodes = Array.wrap(params[:_json])

        # sanitize episodes data
        sanitized_episodes = episodes.map { |ep| EpisodeEvent.sanitize ep }.compact

        added_events = current_user.episode_events.add_events(sanitized_episodes)

        timestamp    = added_events.map(&:timestamp).sort.last
        updated_urls = episodes.map{|e| e[:podcast]}.zip(sanitized_episodes.map{|e| e[:podcast]})

        response = {
          timestamp: timestamp,
          update_urls: updated_urls
        }

        respond_to do |format|
          format.json { render json: response }
        end
      end
    end
  end
end
