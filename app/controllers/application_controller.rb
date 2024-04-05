class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_admin



  def render_turbo_flash
    turbo_stream.update("our_flash", partial: "shared/flash")
  end

  def render_modal
    turbo_stream_action_tag :open_modal, targets: '.modal'
  end


  private

  def current_admin
      current_user.role.name == 'admin' ? true : false
  end

  def authenticate_admin!
    unless current_admin
      redirect_to root_path, alert: "У вас нет прав админа"
    end
  end


  def active_storage_host
    ActiveStorage::Current.host = request.base_url
  end

protected


def configure_permitted_parameters
  attributes = [:email] #[:name, :email]
  devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
end


end
