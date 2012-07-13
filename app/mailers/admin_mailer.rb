# Create a new class to pick up the custom plain-text templates only.
#
# AdminUser is not confirmable or lockable, so we need only define the
# recoverable mailer method.
#
# @see config/initializers/devise.rb
class AdminMailer < Devise::Mailer
  default from: ENV['ACTION_MAILER_FROM']

  def reset_password_instructions(record)
    # We can safely set the locale here, because all controllers set the locale
    # in a before_filter.
    I18n.locale = record.locale || I18n.default_locale
    initialize_from_record(record)
    headers = headers_for(:reset_password_instructions)
    headers.merge! reply_to: ENV['ACTION_MAILER_REPLY_TO']
    headers.delete :template_path
    mail headers
  end
end
