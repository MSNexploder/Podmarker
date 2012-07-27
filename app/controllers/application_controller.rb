class ApplicationController < ActionController::Base
  private

  def current_user
    @current_user
  end
  helper_method :current_user

  def device
    @device
  end
  helper_method :device

  def authenticate
    # existing session
    if session[:user_id]
      @current_user = User.find session[:user_id]
      return
    end

    # http basic auth
    @current_user = authenticate_with_http_basic do |username, password|
      User.authenticate(username, password)
    end

    if @current_user
      session[:user_id] = @current_user.id
    else
      request_http_basic_authentication('Podmarker')
    end
  end

  def find_or_create_device
    device = current_user.devices.find_or_create name: params[:device_id]

    # simply set device active, regardless of the current status
    device.deleted = false

    # throw if something went wrong
    device.save!

    @device = device
  end

  # some clients are not setting current headers - fix params parsing here
  def fix_params_parsing
    return unless request.body.size > 0

    data = ActiveSupport::JSON.decode(request.body)
    request.body.rewind if request.body.respond_to?(:rewind)
    data = {:_json => data} unless data.is_a?(Hash)

    data.each do |key, value|
      params[key] = value unless params.has_key? key
    end
  end
end
