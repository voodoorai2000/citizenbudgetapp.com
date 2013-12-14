class Notifier < ActionMailer::Base
  default from: ENV['ACTION_MAILER_FROM']

  def thank_you(response)
    questionnaire = response.questionnaire

    from = Mail::Address.new(default_params[:from])
    from.display_name = questionnaire.organization.name

    to = Mail::Address.new(response.email)
    to.display_name = response.name if response.name?

    headers = {
      from: from.format,
      to: to.format,
      reply_to: questionnaire.reply_to,
    }

    headers[:subject] = if questionnaire.thank_you_subject?
      questionnaire.thank_you_subject
    else
      t(:thank_you_subject, organization: questionnaire.organization.name, locale: questionnaire.locale)
    end

    mail(headers) do |format|
      format.text do
        options = ActionMailer::Base.default_url_options
        options = options.merge(host: questionnaire.domain) if questionnaire.domain?
        render text: Mustache.render(questionnaire.thank_you_template, {
          name: response.name,
          url: Bitly.shorten(response_url(response, options)),
        })
      end
    end
  end
end
