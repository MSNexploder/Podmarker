module Api
  module V2
    class SubscriptionsController < ApplicationController
      before_filter :authenticate
      before_filter :fix_params_parsing, only: ['update']
      before_filter :find_or_create_device

      def show
        since = params[:since].to_i || 0

        added, removed, timestamp = device.subscription_events.events_since_timestamp(since)
        timestamp = 

        response = {
          add: added,
          remove: removed,
          timestamp: timestamp
        }

        respond_to do |format|
          format.json { render json: response }
        end
      end

      def update
        new_subscriptions     = Array.wrap(params[:add])
        deleted_subscriptions = Array.wrap(params[:remove])

        # sanitize all urls
        sanitized_new_subscriptions     = new_subscriptions.map { |sub| SubscriptionEvent.sanitize_url sub }.compact
        sanitized_deleted_subscriptions = deleted_subscriptions.map { |sub| SubscriptionEvent.sanitize_url sub }.compact

        # adding and deleting the same url -> bad request
        unless (new_subscriptions & deleted_subscriptions).empty?
          render :nothing => true, :status => :bad_request
          return
        end

        added_subscriptions   = device.subscription_events.add_urls(new_subscriptions)
        removed_subscriptions = device.subscription_events.remove_urls(deleted_subscriptions)

        timestamp    = added_subscriptions.map(&:timestamp).sort.last
        updated_urls = new_subscriptions.zip(sanitized_new_subscriptions)

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
