class Notifier < ActionMailer::Base
  default from: 'noreply@citizenbudget.com'

  def thank_you(response)
    questionnaire = response.questionnaire

    to = Mail::Address.new response.email
    to.display_name = response.name if response.name?

    headers = {
      to: to.format,
      subject: t('.subject', organization: questionnaire.organization.name),
    }

    if questionnaire.reply_to?
      headers[:reply_to] = questionnaire.reply_to
    end

    mail(headers) do |format|
      format.text do
        if questionnaire.thank_you_template?
          render text: Mustache.render(questionnaire.thank_you_template, {
            name: response.name,
            url: Bitly.shorten(response_url(response, host: questionnaire.domain_url || 'http://citizenbudget.com/')),
          })
        end
      end
    end
  end
end
