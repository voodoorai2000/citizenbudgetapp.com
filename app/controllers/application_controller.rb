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

  def set_locale
    I18n.locale = params[:locale] || cookies[:locale] || locale_from_domain || :en
    cookies[:locale] = I18n.locale unless cookies[:locale] == I18n.locale
  end

  def locale_from_domain
    # @todo
  end
end
