# In development, you must reload your application for changes in
# ApplicationController to take effect.
#
# @see https://github.com/gregbell/active_admin/issues/697
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  # https://github.com/ryanb/cancan/wiki/exception-handling
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        redirect_to admin_root_path, alert: exception.message
      end
    end
  end

protected

  # https://github.com/ryanb/cancan/wiki/changing-defaults
  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  def set_locale
    I18n.locale = current_admin_user && locale_from_record(current_admin_user) || locale_from_host || locale_from_domain || I18n.default_locale
  end

  def locale_from_record(record)
    record.locale && (
      Locale.available_locales.find{|locale|
        locale.to_s == record.locale
      } ||
      Locale.available_locales.find{|locale|
        locale.to_s.split('-', 2).first == record.locale.split('-', 2).first
      }
    )
  end

  def locale_from_host
    Locale.available_locales.find do |locale|
      request.host == t('app.host', locale: locale)
    end
  end

  def locale_from_domain
    Locale.available_locales.find do |locale|
      request.domain == t('app.domain', locale: locale)
    end
  end
end
