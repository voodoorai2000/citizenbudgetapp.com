class ResponsesController < ApplicationController
  before_filter :find_questionnaire
  before_filter :set_locale

  def new
    maximum = @questionnaire.sections.reduce(0) do |sum,section|
      sum + section.questions.reduce(0) do |sum,q|
        sum + (q.maximum_amount || 0)
      end
    end
    minimum = @questionnaire.sections.reduce(0) do |sum,section|
      sum + section.questions.reduce(0) do |sum,q|
        sum + (q.minimum_amount || 0)
      end
    end
    @maximum_difference = [maximum, -minimum].max
    @groups = @questionnaire.sections.group_by(&:group)
    @response = Response.new initialized_at: Time.now
  end

  def create
    # @todo
  end

  def show
    # @todo
  end

private

  def find_questionnaire
    @questionnaire = Questionnaire.find_by_domain(request.domain) || Questionnaire.first # @todo
  end

  def set_locale
    I18n.locale = I18n.available_locales.find{|x|
      x.to_s == @questionnaire.locale || x.to_s.split('-', 2).first == @questionnaire.locale.split('_', 2).first
    } || I18n.default_locale
  end
end
