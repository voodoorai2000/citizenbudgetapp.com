module ApplicationHelper
  def bootstrap_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    options[:builder] ||= FormtasticBootstrap::FormBuilder
    semantic_form_for record_or_name_or_array, options, &proc
  end

  def system_locale
    locale.to_s.sub('-', '_')
  end

  def iso639_locale
    locale.to_s.split('-', 2).first
  end

  def title
    if @questionnaire
      "#{@questionnaire.organization.name} - #{@questionnaire.title}"
    else
      t '.title'
    end
  end

  def meta_description
    @questionnaire && @questionnaire.description
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
  def facebook_app_id
    @questionnaire && @questionnaire.facebook_app_id
  end

  def google_analytics_tracking_code
    @questionnaire && @questionnaire.google_analytics || t('.google_analytics')
  end
end
