$ ->
  # Local globals.
  amountLeft = 0
  barLeft = 100

  # Open non-Bootstrap links in new windows.
  $('.description a:not([class])').attr 'target', '_blank'

  # Initialize Bootstrap plugins.
  $('.dropdown-toggle').dropdown()

  # Turn popovers into modals on touch devices.
  if $.support.touch or true
    $('.popover-toggle')
      .removeClass('popover-toggle')
      .removeAttr('data-content')
      .removeAttr('data-placement')
      .attr('data-toggle', 'modal')
  else
    $('.popover-toggle').popover().click (event) ->
      event.preventDefault()
    $('a[rel="tooltip"]').tooltip()

  # Navigation
  (->
    if $('nav').length
      $window     = $ window
      $nav        = $ 'nav'
      $message    = $ '#message'
      $whitespace = $ '#whitespace'
      offset      = $nav.length and $nav.offset().top
      height      = $nav.outerHeight() + $message.outerHeight()

      # Set active menu item.
      $('body').scrollspy
        target: 'nav'
        offset: height

      # Smooth scrolling.
      $nav.localScroll
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
        $whitespace.css(height: $nav.outerHeight() + $message.outerHeight()).toggle boolean

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

  # https://github.com/rails/rails/blob/006de2577a978cd212f07df478b03053b1309c84/actionpack/lib/action_view/helpers/number_helper.rb#L231
  # @note rounds the number
  number_with_delimiter = (number) ->
    parts = Math.round(parseFloat(number)).toString().split '.'
    parts[0] = parts[0].replace /(\d)(?=(\d\d\d)+(?!\d))/g, '$1' + t 'currency_delimiter'
    parts.join t('currency_separator')

  # Converts a number to a currency.
  number_to_currency = (number) ->
    Mustache.render t('currency_format'),
      number: number_with_delimiter number
      unit: t 'currency_unit'

  number_to_human = (number) ->
    number = parseFloat(number)
    if Math.abs(number) > 1000
      number /= 1000
      number = "#{number} k"
    number

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
      balance -= ($this.slider('value') - parseFloat($this.attr('data-initial'))) * parseFloat($this.attr('data-value'))
    $table.find('.onoff').each ->
      $this = $ this
      balance -= (+$this.prop('checked') - parseFloat($this.attr('data-initial'))) * parseFloat($this.attr('data-value'))
    balance

  # Updates within-category balance.
  updateCategoryBalance = ($control) ->
    $table  = $control.parents 'table'
    $span   = $ '#' + $table.attr('id') + '_link span'
    if $span.parents('.dropdown-menu').length
      balance = calculateBalance $table
      $span.html(number_to_currency(balance)).css('color', if balance < 0 then '#f00' else '#000').toggle(balance != 0)

  # Updates within-group balance.
  updateBalance = ->
    balance = 0

    $.each ['revenue', 'expense'], (i, group) ->
      amount = $ "##{group} .amount"
      bar = $ "##{group} .bar"

      # Revenue cuts remove money, whereas expenses custs add money.
      group_balance = calculateBalance $("""table[rel="#{group}"]""")
      group_balance = -group_balance if group == 'revenue'
      balance += group_balance

      # Update group balance.
      currency = number_to_currency group_balance
      amount.html(currency).toggleClass 'negative', group_balance < 0

      # Move bar and balance.
      pixels = -Math.round(tanh(3 * group_balance / maximumDifference) * 100)
      width = Math.abs pixels

      # If at zero.
      if bar.width() == 0
        amount.animate left: amountLeft - pixels
        bar.css('background-color', if group_balance < 0 then '#f00' else '#000').animate
          left: Math.min(barLeft, barLeft - pixels)
          width: width
      # If going from negative to positive.
      else if group_balance > 0 and bar.position().left < barLeft
        amount.animate(left: amountLeft).animate(left: amountLeft - pixels)
        bar.animate
          left: barLeft,
          width: 0
        ,
          complete: ->
            $(this).css('background-color', '#000')
        .animate
          width: width
      # If going from positive to negative.
      else if group_balance < 0 and bar.position().left == barLeft
        amount.animate(left: amountLeft).animate(left: amountLeft - pixels)
        bar.animate
          width: 0
        ,
          complete: ->
            $(this).css('background-color', '#f00')
        .animate
          left: barLeft - pixels
          width: width
      # If not crossing zero.
      else
        amount.animate left: amountLeft - pixels
        bar.animate
          left: Math.min(barLeft, barLeft - pixels)
          width: width

    $message = $ '.message'
    currency = number_to_currency balance

    # Update message.
    changed = $('.selected').length
    if balance < 0
      $message.html t('deficit', number: currency)
    else if balance == 0
      if changed
        $message.html t('balanced')
      else
        $message.html t('instructions')
    else
      $message.html t('surplus', number: currency)

    if balance >= 0 and changed
      $message.animate 'background-color': '#ff0', 'color': '#000'
    else if balance < 0
      $message.animate 'background-color': '#f00', 'color': '#fff'
    else if balance == 0
      $message.animate 'background-color': '#666', 'color': '#fff'

    # Enable or disable identification form.
    if balance >= 0 and changed
      enableForm()
    else
      disableForm()

  highlight = ($control, current) ->
    $tr = $control.parents 'tr'
    initial = parseFloat $control.attr('data-initial')
    value = parseFloat $control.attr('data-value')
    group = $control.parents('table').attr 'rel'

    if current == initial
      $tr.find('.impact').css 'visibility', 'hidden'
      if $tr.hasClass 'selected'
        $tr.removeClass 'selected'
        $tr.find('td.description').animate 'background-color': '#fff', 'slow'
        $tr.find('td.highlight').animate {'background-color': if group == 'revenue' then '#ddf' else '#ff9'}, 'slow'
    else
      lower = current - initial < 0
      if group == 'revenue'
        if lower
          key = t('losses')
          color = '#d00'
        else
          key = t('gains')
          color = '#000'
      else
        if lower
          key = t('savings')
          color = '#000'
        else
          key = t('costs')
          color = '#d00'

      $tr.find('.key').html key
      $tr.find('.value').html number_to_currency(Math.abs(current - initial) * value)
      $tr.find('.impact').css('color', color).css 'visibility', 'visible'
      unless $tr.hasClass 'selected'
        $tr.addClass 'selected'
        $tr.find('td').animate 'background-color': '#add5f7', 'fast'

  slide = (event, ui) ->
    $this = $ this
    $this.find('.tip-content').html number_to_human(ui.value)
    # Display tooltip unless value is both zero and the minimum value.
    $this.find('.tip').toggle ui.value != 0 || ui.value != parseFloat($this.attr('data-minimum'))
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
    initial = parseFloat $this.attr('data-initial')
    minimum = parseFloat $this.attr('data-minimum')
    maximum = parseFloat $this.attr('data-maximum')
    actual = parseFloat $this.attr('data-actual')

    $this.slider
      animate: true
      max: maximum
      min: minimum
      range: 'min'
      step: parseFloat $this.attr('data-step')
      value: initial
      create: (event, ui) ->
        $(this).find('a').append '<div class="tip"><div class="tip-content">' + initial + '</div><div class="tip-arrow"></div></div>'
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
    initial = parseFloat $this.attr('data-initial')

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

  if disabled?
    updateBalance()
    $('table').find('input:first').each ->
      updateCategoryBalance $(this)
    $('table .slider').each ->
      $this = $ this
      value = $this.slider 'value'
      $this.find('.tip-content').html number_to_human(value)
      $this.find('.tip').toggle value != 0 || value != parseFloat($this.attr('data-minimum'))
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
      $slider.slider 'value', $slider.attr('data-minimum')

    $('.maximum').click ->
      $this = $ this
      $widget = $this.parents '.widget'
      $widget.find('.onoff').prop('checked', true).trigger 'change'
      $slider = $widget.find '.slider'
      $slider.slider 'value', $slider.attr('data-maximum')

    $('#new_response').validationEngine()
    disableForm()
