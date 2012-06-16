module ResponsesHelper
  def markdown(string)
    RDiscount.new(string).to_html.html_safe
  end

  def escape_attribute(string)
    string.gsub '"', '&quot;'
  end

  def twitter_button
    html_options = {
      'class'      => 'twitter-share-button',
      'data-count' => 'horizontal',
    }
    if @questionnaire
      html_options['data-url']  = @questionnaire.domain_url
      html_options['data-lang'] = t :twitter_locale
      html_options['data-text'] = @questionnaire.twitter_text if @questionnaire.twitter_text?
      html_options['data-via']  = @questionnaire.twitter_screen_name if @questionnaire.twitter_screen_name?
    end
    link_to nil, 'http://twitter.com/share', html_options
  end

  def facebook_button
    html_options = {
      'class'       => 'fb-like',
      'data-send'   => 'true',
      'data-layout' => 'button_count',
      'data-width'  => '175',
    }
    if @questionnaire
      html_options['data-href'] = @questionnaire.domain_url
    end
    content_tag(:div, nil, html_options)
  end
end
