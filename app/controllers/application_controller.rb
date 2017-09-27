class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  after_action :last_accessed_app, :record_recent_commodity


  helper_method :current_app

  def current_app
    App.find_by(id: params[:app_id] || params[:id])
  end


  def last_accessed_app
    return unless request.get?
    return unless request.path.match(/\/apps\/(\d+)/)
    cookies.permanent[:last_app_id] = request.path.match(/\/apps\/(\d+)/)[1]
  end

  def record_recent_commodity
    return unless request.get?
    return unless request.path.match(/\/apps\/\d+\/commodities\/(\d+)/)
    commodities = cookies.permanent[:recent_commodities] || []
    commodity_id = request.path.match(/\/apps\/\d+\/commodities\/(\d+)/)[1]
    if commodities.empty?
      commodities << commodity_id
    else
      commodities = cookies.permanent[:recent_commodities].split(",")
      commodities.delete(commodity_id) if commodities.include?(commodity_id)
      commodities.unshift(commodity_id)
      commodities.pop if commodities.size > 5
    end
    cookies.permanent[:recent_commodities] = commodities.join(",")
  end

  def after_sign_in_path_for(resource)
    return root_path unless cookies[:last_app_id]
    app = App.find_by(id: cookies[:last_app_id])
    return root_path if app.nil?
    app_path(app)
  end
end