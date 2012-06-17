module ApplicationHelper
  def title
    if @questionnaire
      "#{@questionnaire.organization.name} - #{@questionnaire.title}"
    else
      t '.title'
    end
  end

  def meta_description
    '' # @todo add another field to Questionnaire?
  end

  def author
    @questionnaire && @questionnaire.organization.name || t('.author')
  end

  # Open Graph tags
  def og_title
    title
  end

  def og_description
    meta_description
  end

  def og_site_name
    @questionnaire && @questionnaire.title || t('.title')
  end

  def og_url
    @questionnaire && @questionnaire.domain_url || t('.og_url')
  end

  def og_image
    if @questionnaire && @questionnaire.logo?
      if Rails.env.production?
        'http:' + @questionnaire.logo_url
      else
        root_url.chomp('/') + @questionnaire.logo_url
      end
    end
  end

  # Facebook tags
  def facebook_locale
    @questionnaire && @questionnaire.system_locale || t('.facebook_locale')
  end

  def facebook_app_id
    @questionnaire && @questionnaire.facebook_app_id
  end

  def google_analytics_tracking_code
    @questionnaire && @questionnaire.google_analytics || t('.google_analytics')
  end
end
