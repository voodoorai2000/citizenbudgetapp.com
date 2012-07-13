class ResponsesController < ApplicationController
  before_filter :find_questionnaire
  before_filter :set_locale
  caches_action :new, :show

  def new
    @response = @questionnaire.responses.build initialized_at: Time.now.utc, newsletter: true, subscribe: true
    build_questionnaire
    fresh_when @questionnaire, public: true
  end

  def create
    @response = @questionnaire.responses.build params[:response]
    @response.answers = params.select{|k,_| k[/\A[a-f0-9]{24}\z/]}
    @response.ip      = request.ip
    @response.save! # There shouldn't be errors.
    Notifier.thank_you(@response).deliver if @response.email.present?
    redirect_to @response, notice: t(:create_response)
  end

  def show
    @response = @questionnaire.responses.find params[:id]
    build_questionnaire
    fresh_when @response, public: true
  end

private

  def find_questionnaire
    @questionnaire = Questionnaire.find_by_domain(request.host) || Questionnaire.last # Useful in development
  end

  def set_locale
    I18n.locale = Locale.available_locales.find{|x|
      x.to_s == @questionnaire.locale
    } || Locale.available_locales.find{|x|
      x.to_s.split('-', 2).first == @questionnaire.locale.split('-', 2).first
    } || I18n.default_locale
  end

  def build_questionnaire
    @groups = @questionnaire.sections.group_by(&:group)
    @maximum_difference = [
      @questionnaire.maximum_amount.abs,
      -@questionnaire.minimum_amount.abs,
    ].max
  end
end
