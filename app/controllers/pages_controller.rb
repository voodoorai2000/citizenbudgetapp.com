class PagesController < ApplicationController
  before_filter :find_questionnaire

  def index
    # @todo
  end

  def channel
    render layout: false
  end

private

  def find_questionnaire
    @questionnaire = Questionnaire.find_by_domain(request.domain) || Questionnaire.first # @todo
  end
end
