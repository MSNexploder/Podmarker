module Api
  module V2
    class DevicesController < ApplicationController
      before_filter :authenticate
      before_filter :fix_params_parsing,    only: ['update']
      before_filter :find_or_create_device, only: ['update']

      def show
        response = current_user.devices.map do |device|
          {
            id:            device.name,
            caption:       device.caption || '',
            type:          device.device_type || '',
            subscriptions: device.subscription_count
          }
        end

        respond_to do |format|
          format.json { render json: response }
        end
      end

      def update
        values = params.slice(:caption, :type)
        values[:device_type] = values.delete(:type) if values.has_key? :type
        device.update_attributes values

        respond_to do |format|
          format.json { render :nothing => true, :status => :ok }
        end
      end
    end
  end
end
