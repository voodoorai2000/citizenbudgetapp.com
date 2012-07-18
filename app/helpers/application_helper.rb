module ApplicationHelper
  def bootstrap_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    options[:builder] ||= FormtasticBootstrap::FormBuilder
    semantic_form_for record_or_name_or_array, options, &proc
  end

  # Facebook uses underscores in locale identifiers (as do Unix systems).
  def system_locale
    locale.to_s.sub('-', '_')
  end

  def iso639_locale
    locale.to_s.split('-', 2).first
  end

  # <head> tags

  def title
    if @questionnaire
      "#{@questionnaire.organization.name} - #{@questionnaire.title}"
    else
      t 'app.product_name'
    end
  end

  def meta_description
    @questionnaire && @questionnaire.description
  end

  def author
    @questionnaire && @questionnaire.organization.name || t('app.author_name')
  end

  # Open Graph tags

  def og_title
    title
  end

  def og_description
    meta_description
  end

  def og_site_name
    @questionnaire && @questionnaire.title || t('app.product_name')
  end

  def og_url
    @questionnaire && @questionnaire.domain_url || t('app.product_url')
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

  # Third-party integration

  def facebook_app_id
    @questionnaire && @questionnaire.facebook_app_id
  end

  def google_analytics_tracking_code
    @questionnaire && @questionnaire.google_analytics || t('.google_analytics')
  end

  # Used in both public and private controllers.

  def token_url(questionnaire)
    root_url(token: questionnaire.authorization_token)
  end

  MAX_DIMENSION = 560 # As for Bootstrap's .modal

  def speakerdeck(html)
    ratio = html[/data-ratio="([0-9.]+)"/, 1].to_f
    if ratio.zero?
      html.html_safe
    else
      # @see http://speakerdeck.com/assets/embed.js
      if ratio >= 1
        width  = MAX_DIMENSION
        height = ((width - 2) / ratio + 64).round
        margin = 0
      else
        height = MAX_DIMENSION
        width  = ((height - 64) * ratio + 2).round
        margin = ((MAX_DIMENSION - width) / 2.0).round
      end
      content_tag(:div, html.html_safe, style: "width:#{width}px;height:#{height}px;margin-left:#{margin}px")
    end
  end
end
