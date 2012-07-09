class ApplicationController < ActionController::Base
  protect_from_forgery

  # https://github.com/ryanb/cancan/wiki/exception-handling
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        redirect_to admin_root_path, alert: exception.message
      end
    end
  end

  # https://github.com/ryanb/cancan/wiki/changing-defaults
  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  def google_client
    if @google_client.nil?
      @google_client = GoogleClient.new oauth2callback_url
      begin
        @google_client.refresh! current_admin_user.google_token
      rescue GoogleClient::AccessRevokedError
        current_admin_user.delete_token!
      end
    end
    @google_client
  end

  helper_method :google_client
end
