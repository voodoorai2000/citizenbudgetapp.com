# In development, you must reload your application for changes in
# ApplicationController to take effect.
#
# @see https://github.com/gregbell/active_admin/issues/697
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

protected

  def set_locale
    I18n.locale = params[:locale] || cookies[:locale] || current_admin_user && locale_from_record(current_admin_user) || locale_from_host || locale_from_domain || I18n.default_locale
    cookies[:locale] = I18n.locale unless cookies[:locale] == I18n.locale
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

  # Useful for debugging.
  def access_denied(exception)
    flash[:error] = exception.message

    if request.headers['Referer']
      redirect_to :back
    else
      controller, action = active_admin_namespace.root_to.split('#')
      if params[:controller].split('/').last == controller && params[:action] == action
        raise [exception.user, exception.action, exception.subject].map(&:inspect).inspect
      else
        redirect_to controller: controller, action: action
      end
    end
  end
end
