class Notifier < ActionMailer::Base
  default from: 'noreply@citizenbudget.com'

  def thank_you(response)
    address = Mail::Address.new response.email
    address.display_name = response.name if response.name?

    mail({
      to: address.format,
      subject: t('.subject', organization: @response.questionnaire.organization.name),
    }) do |format|
      format.text do
        if response.questionnaire.thank_you_template?
          render text: Mustache.render(response.questionnaire.thank_you_template, {
            name: response.name,
            url: Bitly.shorten(response_url(@response)),
          })
        end
      end
    end
  end
end
