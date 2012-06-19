class ResponsesController < ApplicationController
  before_filter :find_questionnaire
  before_filter :set_locale

  def new
    @response = @questionnaire.responses.build({
      initialized_at: Time.now.utc,
      newsletter: true,
      subscribe: true,
    })

    @groups = @questionnaire.sections.group_by(&:group)
    @maximum_difference = [
      @questionnaire.maximum_amount.abs,
      -@questionnaire.minimum_amount.abs,
    ].max
  end

  def create
    @response = @questionnaire.responses.build params[:response]
    @response.answers = params.select{|k,_| k[/\A[a-f0-9]{24}\z/]}
    @response.ip      = request.ip
    @response.save! # There shouldn't be errors.
    # @todo send the person an email thanking them and asking them to forward to friends
    redirect_to @response, notice: t(:create_response)
  end

  def show
    @response = @questionnaire.responses.find params[:id]

    @groups = @questionnaire.sections.group_by(&:group)
    @maximum_difference = [
      @questionnaire.maximum_amount.abs,
      -@questionnaire.minimum_amount.abs,
    ].max
  end

private

  def find_questionnaire
    @questionnaire = Questionnaire.find_by_domain(request.domain) || Questionnaire.first # @todo Remove default
  end

  def set_locale
    I18n.locale = I18n.available_locales.find{|x|
      x.to_s == @questionnaire.locale
    } || I18n.available_locales.find{|x|
      x.to_s.split('-', 2).first == @questionnaire.locale.split('-', 2).first
    } || I18n.default_locale
  end
end
