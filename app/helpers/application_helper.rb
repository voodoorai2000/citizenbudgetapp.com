module ApplicationHelper
  def title
    if @questionnaire
      "#{@organization.name} - #{@questionnaire.title}"
    elsif @organization
      @organization.name
    else
      t '.title'
    end
  end

  def meta_description
    # @todo
  end

  def og_image
    # @todo
  end

  def author
    @organization && @organization.name || t('.author')
  end

  def facebook_locale
    @organization && @organization.locale || 'en_US'
  end

  def google_analytics_tracking_code
    @questionnaire.google_analytics || t('.google_analytics')
  end
end
