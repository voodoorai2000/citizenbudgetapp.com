$ ->
  # Sharing.
  $(document).on 'mouseup', '#url-field', ->
    $(this).select()

  $('.clippy').clippy
    clippy_path: '/assets/clippy.swf'
    text: $('#url-field').val()
    flashvars:
      args: 'clippy'

  window.clippyCopiedCallback = (args) ->
    $('#' + args).attr('data-original-title', t('copied_hint')).tooltip('show').attr('data-original-title', t('copy_hint'))

  # Local globals.
  amount_left = 0
  bar_left = 100
  assessment_period = 12.0 # monthly

  colors =
    revenue:
      negative: '#f00'
      positive: '#000'
    expense:
      negative: '#000'
      positive: '#f00'
    services:
      message:
        background:
          negative: '#f00'
          positive: '#ff0'
        foreground:
          negative: '#fff'
          positive: '#000'
      item:
        negative: '#d00'
        positive: '#000'
    taxes:
      message:
        background:
          negative: '#000'
          positive: '#000'
        foreground:
          negative: '#fff'
          positive: '#fff'
      item:
        positive: '#000'
        negative: '#000'

  # Open non-Bootstrap links in new windows.
  $('.description a:not([class])').attr 'target', '_blank'

  # Initialize Bootstrap plugins.
  $('.dropdown-toggle').dropdown()

  # Turn popovers into modals on touch devices.
  if $.support.touch
    $('.popover-toggle')
      .removeClass('popover-toggle')
      .removeAttr('data-content')
      .removeAttr('data-placement')
      .attr('data-toggle', 'modal')
  else
    $('.popover-toggle').popover(trigger: 'manual', delay: {show: 1, hide: 200}).each ->
      that = $(this).data('popover')
      that.$element.on 'mouseenter', $.proxy(that.enter, that)
      that.$element.on 'mouseleave', $.proxy(that.leave, that)
    .click (event) ->
      event.preventDefault()
    $('[rel="tooltip"]').tooltip()

  $('.modal').bind 'shown', ->
    $(this).removeClass 'invisible'
  $('.modal').bind 'hidden', ->
    $(this).addClass 'invisible'

  # Navigation
  (->
    # If we want a fixed top bar.
    if $('#whitespace').length
      $window     = $ window
      $nav        = $ 'nav'
      $message    = $ '#message'
      $whitespace = $ '#whitespace'

      if $nav.length
        target = 'nav'
        offset = $nav.offset().top
        height = $nav.outerHeight() + $message.outerHeight()
        $receiver = $nav
      else
        target = '#message'
        offset = $message.offset().top
        height = $message.outerHeight()
        $receiver = $message

      # Set active menu item.
      $('body').scrollspy
        target: target
        offset: height

      # Smooth scrolling.
      $receiver.localScroll
        axis: 'y'
        duration: 500
        easing: 'easeInOutExpo'
        offset: -height
        hash: true

      # Fixed menu.
      processScroll = ->
        boolean = $window.scrollTop() >= offset
        $nav.toggleClass 'nav-fixed', boolean
        $message.toggleClass 'message-fixed', boolean
        $whitespace.css(height: height).toggle boolean

      $window.on 'scroll', processScroll
      processScroll()
  )()

  # Smooth scroll "submit your choices" link.
  $('.message').on 'click', 'a[href="#identification"]', (event) ->
    $.scrollTo '#identification',
      axis: 'y'
      duration: 500
      easing: 'easeInOutExpo'
      offset: -50
    event.preventDefault()

  # http://www.musicdsp.org/showone.php?id=238
  tanh = (x) ->
    if x < -3
      -1
    else if x > 3
      1
    else
      x * (27 + x * x) / (27 + 9 * x * x)

  # @see https://github.com/rails/rails/blob/006de2577a978cd212f07df478b03053b1309c84/actionpack/lib/action_view/helpers/number_helper.rb#L208
  number_with_delimiter = (number) ->
    parts = number.toString().split '.'
    parts[0] = parts[0].replace /(\d)(?=(\d\d\d)+(?!\d))/g, '$1' + t('currency_delimiter')
    parts.join t('currency_separator')

  # @see https://github.com/rails/rails/blob/006de2577a978cd212f07df478b03053b1309c84/actionpack/lib/action_view/helpers/number_helper.rb#L254
  # @note Doesn't implement :significant option.
  number_with_precision = (number, options = {}) ->
    options.precision ?= 2
    # toFixed has unpredictable rounding, but small rounding errors are not an issue.
    formatted_number = number_with_delimiter parseFloat(number).toFixed(options.precision)
    if options.strip_insignificant_zeros
      escaped_separator = t('currency_separator').replace ///(
        [
          .     # Dot
          ?*+{} # Quantification
          [\]   # Character set
          ()    # Grouping
          ^$    # Anchors
          |     # Alternation
          \\    # Escape character
          \#    # Comment
          -     # Hyphen
        ]
      )///g, '\\$1'
      # Only strip zeroes if all are insignificant. (Differs from Rails code.)
      formatted_number.replace ///#{escaped_separator}0+$///, ''
    else
      formatted_number

  # Converts a number to a currency.
  number_to_currency = (number, options = {}) ->
    Mustache.render t('currency_format'),
      number: number_with_precision number, options
      unit: t 'currency_unit'

  # Converts a number to a percentage.
  number_to_percentage = (number, options = {}) ->
    Mustache.render t('percentage_format'),
      number: number_with_precision number, options
      symbol: t 'percentage_symbol'

  # Abbreviates a number.
  # @todo use JavaScript I18n method.
  number_to_human = (number, options = {}) ->
    number = parseFloat(number)
    options.strip_insignificant_zeros ?= true
    if Math.abs(number) > 1000
      "#{number_with_precision number / 1000, options} k"
    else
      number_with_precision number, options

  # @return [Integer] the participant's custom property assessment
  # @todo Non-English participants may enter a comma as the decimal mark.
  customAssessment = ->
    parseFloat $('#assessment input').val().replace(/[^0-9.]/, '')

  # @return [Integer] the participant's property assessment
  propertyAssessment = ->
    customAssessment() || default_assessment

  # @return [String] content for the tip on a slider
  tipContent = ($slider, number) ->
    if $slider.data('widget') is 'scaler'
      if questionnaire_mode is 'taxes'
        tip = number_to_currency taxAmount($slider, number), strip_insignificant_zeros: true
      else
        tip = number_to_percentage number * 100, strip_insignificant_zeros: true
    else
      tip = number_to_human number

  taxAmount = ($slider, number) ->
    parseFloat(number) * parseFloat($slider.data('value')) * propertyAssessment() / assessment_period

  # Enables the identification form.
  enableForm = ->
    $('#identification').css 'opacity', 1
    $('#identification input,#identification textarea').prop 'disabled', false

  # Disables the identification form.
  disableForm = ->
    $('#identification').css 'opacity', 0.5
    $('#identification input,#identification textarea').prop 'disabled', true

  # Calculates within-group or within-category balance.
  calculateBalance = ($table) ->
    balance = 0
    $table.find('.slider').each ->
      $this = $ this
      balance -= ($this.slider('value') - parseFloat($this.data('initial'))) * parseFloat($this.data('value'))
    $table.find('.onoff').each ->
      $this = $ this
      balance -= (+$this.prop('checked') - parseFloat($this.data('initial'))) * parseFloat($this.data('value'))
    balance *= propertyAssessment() / assessment_period if questionnaire_mode is 'taxes'
    balance

  # Updates within-category balance.
  updateCategoryBalance = ($control) ->
    $table = $control.parents 'table'
    $span  = $ '#' + $table.attr('id') + '_link span'
    if $span.parents('.dropdown-menu').length
      balance = calculateBalance $table
      $span.html(number_to_currency(balance, strip_insignificant_zeros: true)).css('color', if balance < 0 then '#f00' else '#000').toggle(balance != 0)

  # Updates within-group balance.
  updateBalance = ->
    balance = 0
    current_maximum_difference = maximum_difference

    if questionnaire_mode is 'taxes'
      current_maximum_difference *= propertyAssessment() / assessment_period
      monthly_payment = tax_rate * propertyAssessment() / assessment_period

    $.each ['revenue', 'expense'], (i, group) ->
      group_balance = calculateBalance $("""table[rel="#{group}"]""")

      # Calculate pixels before we inverse the sign of +group_balance+. If
      # pixels are less than zero, the bar moves right (increase).
      pixels = Math.round(tanh(3 * group_balance / current_maximum_difference) * 100)

      # Revenue cuts remove money, whereas expenses custs add money.
      group_balance = -group_balance if group is 'revenue'
      balance += group_balance

      # Update group balance, and move bar and balance.
      if $("##{group}").length
        $amount = $ "##{group} .amount"
        $bar = $ "##{group} .bar"

        amount = number_to_currency group_balance, strip_insignificant_zeros: true
        $amount.html(amount).toggleClass 'negative', group_balance < 0

        width = Math.abs pixels

        # If at zero.
        if $bar.width() == 0
          $amount.animate left: amount_left - pixels
          $bar.css('background-color', if pixels < 0 then colors[group].positive else colors[group].negative).animate
            left: Math.min(bar_left, bar_left - pixels)
            width: width
        # If going from negative to positive.
        else if pixels < 0 and $bar.position().left < bar_left
          $amount.animate(left: amount_left).animate(left: amount_left - pixels)
          $bar.animate
            left: bar_left,
            width: 0
          ,
            complete: ->
              $(this).css('background-color', colors[group].positive)
          .animate
            width: width
        # If going from positive to negative.
        else if pixels > 0 and $bar.position().left == bar_left
          $amount.animate(left: amount_left).animate(left: amount_left - pixels)
          $bar.animate
            width: 0
          ,
            complete: ->
              $(this).css('background-color', colors[group].negative)
          .animate
            left: bar_left - pixels
            width: width
        # If not crossing zero.
        else
          $amount.animate left: amount_left - pixels
          $bar.animate
            left: Math.min(bar_left, bar_left - pixels)
            width: width

    # Update message.
    $messages = $ '.message'
    $message = $ '#message'
    $reminder = $ '#reminder'

    if questionnaire_mode is 'taxes'
      number = number_to_currency Math.abs(balance), strip_insignificant_zeros: true
      percentage = number_to_percentage Math.abs(balance) / monthly_payment * 100, strip_insignificant_zeros: true
    else
      number = number_to_currency balance, strip_insignificant_zeros: true
      percentage = 0

    changed = $('.selected').length
    if balance < 0
      $messages.html t("#{questionnaire_mode}_deficit", number: number, percentage: percentage)
    else if balance == 0
      if changed
        $messages.html t("#{questionnaire_mode}_balanced")
      else
        $reminder.html('&nbsp;')
        $message.html t('instructions')
    else
      $messages.html t("#{questionnaire_mode}_surplus", number: number, percentage: percentage)

    if balance >= 0 and changed
      $message.animate 'background-color': colors[questionnaire_mode].message.background.positive, 'color': colors[questionnaire_mode].message.foreground.positive
    else if balance < 0
      $message.animate 'background-color': colors[questionnaire_mode].message.background.negative, 'color': colors[questionnaire_mode].message.foreground.negative
    else if balance == 0
      $message.animate 'background-color': '#666', 'color': '#fff'

    # Enable or disable identification form.
    if changed and (questionnaire_mode is 'taxes' or balance >= 0)
      enableForm()
    else
      disableForm()

  highlight = ($control, current) ->
    $tr = $control.parents 'tr'
    initial = parseFloat $control.data('initial')
    value = parseFloat $control.data('value')
    group = $control.parents('table').attr 'rel'

    if current == initial
      $tr.find('.impact').css 'visibility', 'hidden'
      if $tr.hasClass 'selected'
        $tr.removeClass 'selected'
        $tr.find('td.description').animate 'background-color': '#fff', 'slow'
        $tr.find('td.highlight').animate {'background-color': if group is 'revenue' then '#ddf' else '#ff9'}, 'slow'
    else
      lower = current - initial < 0
      if group is 'revenue'
        if lower
          key = t("#{questionnaire_mode}_losses")
          color = colors[questionnaire_mode].item.negative
        else
          key = t("#{questionnaire_mode}_gains")
          color = colors[questionnaire_mode].item.positive
      else
        if lower
          key = t("#{questionnaire_mode}_savings")
          color = colors[questionnaire_mode].item.positive
        else
          key = t("#{questionnaire_mode}_costs")
          color = colors[questionnaire_mode].item.negative

      $tr.find('.key').html key
      difference = Math.abs(current - initial) * value
      difference *= propertyAssessment() / assessment_period if questionnaire_mode is 'taxes'
      $tr.find('.value').html number_to_currency(difference, strip_insignificant_zeros: true)
      $tr.find('.impact').css('color', color).css 'visibility', 'visible'
      unless $tr.hasClass 'selected'
        $tr.addClass 'selected'
        $tr.find('td').animate 'background-color': '#add5f7', 'fast'

  slide = (event, ui) ->
    $this = $ this
    $this.find('.tip-content').html tipContent($this, ui.value)
    # Display tooltip unless value is both zero and the minimum value.
    $this.find('.tip').toggle ui.value != 0 || ui.value != parseFloat($this.data('minimum'))
    highlight $this, ui.value

  change = (event, ui) ->
    $this = $ this
    # Perform same operations as if sliding.
    slide.call this, event, ui
    # Update form element.
    $this.find('input').val ui.value
    # Updating balance during slide is too expensive.
    updateCategoryBalance $this
    updateBalance()

  # Slider widget
  $('table .slider').each ->
    $this = $ this
    initial = parseFloat $this.data('initial')
    minimum = parseFloat $this.data('minimum')
    maximum = parseFloat $this.data('maximum')
    actual = parseFloat $this.data('actual')

    $this.slider
      animate: true
      max: maximum
      min: minimum
      range: 'min'
      step: parseFloat $this.data('step')
      value: initial
      create: (event, ui) ->
        $(this).find('a').append '<div class="tip"><div class="tip-content">' + tipContent($this, initial) + '</div><div class="tip-arrow"></div></div>'
        $(this).find('.tip').toggle initial != minimum
      slide: !disabled? && slide
      change: !disabled? && change
      disabled: disabled?

    # Place initial tick.
    if initial != maximum and initial != minimum
      $this.find('.tick.initial').width($this.find('a').position().left + 1).show()

    # We place the initial tick according to the handle's position, so we can't
    # set the value during slider initialization.
    unless isNaN actual
      $this.slider 'value', actual

  # Keyboard input can be confusing if slider is not visible.
  $('.ui-slider-handle').unbind 'keydown'

  # On/off widget
  $('table .onoff').each ->
    $this = $ this
    initial = parseFloat $this.data('initial')

    options =
      resizeContainer: false
      onChange: (input, checked) ->
        highlight input, +checked
        updateCategoryBalance input
        updateBalance()

    if initial == 1
      options.checkedLabel = t 'no'
      options.uncheckedLabel = t 'yes'
      options.labelOffClass = 'iPhoneCheckLabelOff reverse'
      options.labelOnClass = 'iPhoneCheckLabelOn reverse'
    else
      options.resizeContainer = false
      options.checkedLabel = t 'yes'
      options.uncheckedLabel = t 'no'
    $this.iphoneStyle options

  # Questionnaire mode is "taxes" if "#assessment" is present.
  $('#assessment input').blur ->
    # Ignore invalid assessment values.
    if customAssessment() <= 0
      $('#assessment input').val('')

    updateBalance()
    $('table').find('input:first').each ->
      updateCategoryBalance $(this)

    $('.widget-scaler').each ->
      $widget = $ this
      $slider = $widget.find '.slider'
      $widget.find('.minimum.taxes').html number_to_currency taxAmount($slider, $slider.data('minimum'))
      $widget.find('.maximum.taxes').html number_to_currency taxAmount($slider, $slider.data('maximum'))

  if disabled?
    updateBalance()
    $('table').find('input:first').each ->
      updateCategoryBalance $(this)

    $('table .slider').each ->
      $this = $ this
      value = $this.slider 'value'
      $this.find('.tip-content').html tipContent($this, value)
      $this.find('.tip').toggle value != 0 || value != parseFloat($this.data('minimum'))
      highlight $this, value

    $('table .onoff').each ->
      $this = $ this
      highlight $this, +$this.prop('checked')
  else
    $('.minimum').click ->
      $this = $ this
      $widget = $this.parents '.widget'
      $widget.find('.onoff').prop('checked', false).trigger 'change'
      $slider = $widget.find('.slider')
      $slider.slider 'value', $slider.data('minimum')

    $('.maximum').click ->
      $this = $ this
      $widget = $this.parents '.widget'
      $widget.find('.onoff').prop('checked', true).trigger 'change'
      $slider = $widget.find '.slider'
      $slider.slider 'value', $slider.data('maximum')

    $('#new_response').validationEngine()
    disableForm()
