module ResponsesHelper
  def logo
    options = {alt: ''}
    if @questionnaire.logo_height?
      options[:height] = [@questionnaire.logo_height, 100].min
    end
    link_to_unless_current image_tag(@questionnaire.logo.large.url, options), root_path
  end

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

  def html_attributes(question)
    attributes = {}
    classes = []

    value = question.default_value
    attributes[:value] = value if value.present?

    [:size, :maxlength, :placeholder, :rows, :cols].each do |attribute|
      value = question[attribute]
      attributes[attribute] = value if value.present?
    end

    if question.size.present? || question.cols.present?
      span = case question.size || question.cols # 210px is the default
      when 0..5
        'span1' # 50px
      when 6..18
        'span2' # 130px
      when 33..45
        'span4' # 290px
      when 46..58
        'span5' # 370px
      when 59..72
        'span6' # 450px
      when 73..85
        'span7' # 530px
      when 86..98
        'span8' # 610px
      when 99..112
        'span9' # 690px
      when 113..125
        'span10' # 770px
      end
      classes << span if span
    end

    if question.required?
      attributes[:required] = Formtastic::FormBuilder.use_required_attribute
      classes << 'validate[required]'
    end

    attributes[:class] = classes.join(' ') unless classes.empty?
    attributes
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
      'data-width'      => t(:facebook_width),
    }
    if @questionnaire
      html_options['data-href'] = @questionnaire.domain_url
    end
    content_tag(:div, nil, html_options.merge(options))
  end

  # Only strip zeroes if all are insignificant.
  def currency(number, options = {})
    escaped_separator = Regexp.escape t(:'number.currency.format.separator', default: [:'number.format.separator', '.'])
    # This logic should be in number_with_precision, but as long as the
    # separator occurs only once, this is safe.
    number_to_currency(number, options).sub /#{escaped_separator}0+\b/, ''
  end

  # @return [Integer] one column if the section has nonbudgetary questions only
  def colspan(section)
    section.nonbudgetary? && 1 || 2 # @feature widgets
  end

  # Display a menu if there are multiple groups and/or sections.
  def simple_navigation?
    @groups.one? && @groups.values[0].one?
  end
end
