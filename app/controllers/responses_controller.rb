class ResponsesController < ApplicationController
  before_filter :find_questionnaire
  before_filter :set_locale

  def new
    @maximum_difference = [
      @questionnaire.maximum_amount.abs,
      -@questionnaire.minimum_amount.abs,
    ].max
    @groups = @questionnaire.sections.group_by(&:group)
    @response = @questionnaire.responses.build initialized_at: Time.now.utc, subscribe: true
  end

  def create
    @response = @questionnaire.responses.build params[:response]
    @response.answers = params.select{|k,_| k[/\A[a-f0-9]{24}\z/]}
    @response.ip      = request.ip
    @response.save! # There shouldn't be errors.
    redirect_to @response, notice: t(:create_response)
  end

  def show
    @response = @questionnaire.responses.find params[:id]
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
