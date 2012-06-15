class ResponsesController < ApplicationController
  before_filter :find_questionnaire

  def new
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
end
