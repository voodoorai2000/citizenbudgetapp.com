class ResponsesController < ApplicationController
  before_filter :find_questionnaire
  before_filter :set_locale

  def new
    @maximum_difference = [
      @questionnaire.maximum_amount.abs,
      -@questionnaire.minimum_amount.abs,
    ].max
    @groups = @questionnaire.sections.group_by(&:group)
    @response = Response.new initialized_at: Time.now, subscribe: true
  end

  def create
    # @todo
  end

  def show
    # @todo
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
