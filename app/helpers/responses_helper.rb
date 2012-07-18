module ResponsesHelper
  # Surrounds a string with locale-appropriate curly quotes.
  def curly_quote(string)
    "#{t(:left_quote)}#{string}#{t(:right_quote)}"
  end

  def markdown(string)
    RDiscount.new(string).to_html.html_safe
  end

  # Escapes double-quotes for inclusion in HTML attributes.
  def escape_attribute(string)
    string.gsub '"', '&quot;'
  end

  def twitter_button(options = {})
    html_options = {
      'class'      => 'twitter-share-button',
      'data-count' => 'horizontal',
      'data-lang'  => iso639_locale,
    }
    if @questionnaire
      html_options['data-text'] = @questionnaire.twitter_text if @questionnaire.twitter_text?
      html_options['data-url']  = @questionnaire.domain_url
      html_options['data-via']  = @questionnaire.twitter_screen_name if @questionnaire.twitter_screen_name?
    end
    link_to nil, 'http://twitter.com/share', html_options.merge(options)
  end

  def facebook_button(options = {})
    html_options = {
      'class'           => 'fb-like',
      'data-send'       => 'true',
      'data-layout'     => 'button_count',
      'data-show-faces' => 'false',
      'data-width'      => '175',
    }
    if @questionnaire
      html_options['data-href'] = @questionnaire.domain_url
    end
    content_tag(:div, nil, html_options.merge(options))
  end

  # Only strip zeroes if all are insignificant.
  def currency(number)
    escaped_separator = Regexp.escape t(:'number.currency.format.separator', default: [:'number.format.separator', '.'])
    number_to_currency(number).sub /#{escaped_separator}0+\z/, ''
  end

  def colspan(section)
    section.survey? && 1 || 2
  end

  # Display a menu if there are multiple groups and/or sections.
  def simple_navigation?
    @groups.size == 1 && @groups.values[0].size == 1
  end
end
