module Api
  module V2
    class EpisodesController < ApplicationController
      before_filter :authenticate
      before_filter :fix_params_parsing, only: ['show', 'update']

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
