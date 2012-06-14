module ApplicationHelper
  def title
    if @questionnaire
      "#{@questionnaire.organization.name} - #{@questionnaire.title}"
    else
      t '.title'
    end
  end

  def meta_description
    # @todo
  end

  def og_title
    title
  end
  def og_description
    meta_description
  end
  def og_site_name
    if @questionnaire
      @questionnaire.title
    else
      t '.title'
    end
  end
  def og_image
    # @todo
  end

  def author
    @questionnaire && @questionnaire.organization.name || t('.author')
  end

  def facebook_locale
    @questionnaire && @questionnaire.organization.locale || 'en_US'
  end

  def facebook_app_id
    @questionnaire && @questionnaire.facebook_app_id
  end

  def google_analytics_tracking_code
    @questionnaire.google_analytics || t('.google_analytics')
  end
end
