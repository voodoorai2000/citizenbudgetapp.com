$ ->
  amountLeft = 0
  barLeft = 100

  # Bootstrap plugins
  $('.dropdown-toggle').dropdown()
  $('.popover-toggle').popover()
  $('a[rel="tooltip"]').tooltip()

  # Navigation
  if $('nav').length
    $window = $ window
    $nav    = $ 'nav'
    offset  = $nav.length && $nav.offset().top

    # Set active menu item.
    $('body').scrollspy
      target: 'nav'
      offset: 50

    # Smooth scrolling.
    $nav.localScroll
      axis: 'y'
      duration: 500
      easing: 'easeInOutExpo'
      offset: -50
      hash: true

    # Fixed menu.
    processScroll = ->
      $nav.toggleClass 'nav-fixed', $window.scrollTop() >= offset
    $window.on 'scroll', processScroll
    processScroll()

  # http://www.musicdsp.org/showone.php?id=238
  tanh = (x) ->
    if x < -3
      -1
    else if x > 3
      1
    else
      x * (27 + x * x) / (27 + 9 * x * x)

  # Converts a number to a currency.
  number_to_currency = (number) ->
    Mustache.render t('currency_format'),
      number: number.toString().replace /(\d)(?=(\d\d\d)+(?!\d))/g, '$1' + t 'currency_delimiter'
      unit: t 'currency_unit'

  # Enables the identification form.
  enableForm = ->
    $('#identification').css 'opacity', 1
    $('#identification input,#identification textarea').prop 'disabled', false

  # Disables the identification form.
  disableForm = ->
    $('#identification').css 'opacity', 0.5
    $('#identification input,#identification textarea').prop 'disabled', true

  # Updates within-category balance.
  updateCategoryBalance = ($control) ->
    $table = $control.parents 'table'
    balance = 0

    # @todo
    #$table.find('.slider').each ->
    #  var $this = $(this);
    #  balance -= ($this.slider('value') - parseInt($this.attr('data-initial'))) * parseInt($this.attr('data-value'));
    $table.find(':checkbox').each ->
      $this = $ this
      balance -= (+$this.prop('checked') - parseFloat($this.attr('data-initial'))) * parseFloat($this.attr('data-value'))

    $('#' + $table.attr('id') + '_link span').html(number_to_currency(balance)).css('color', balance < 0 ? '#f00' : '#000').toggle(balance != 0)

  # Updates within-group balance.
  updateBalance = ->
    balance = 0
    changed = false

    $.each ['revenue', 'expense'], (i, group) ->
      group_balance = 0
      amount = $ "##{group} .amount"
      bar = $ "##{group} .bar"

      # Calculate balance.
      # @todo
      #$('.slider').each ->
      #  $this = $ this
      #  difference = $this.slider('value') - parseFloat($this.attr('data-initial'))
      #  group_balance -= difference * parseFloat($this.attr('data-value'))
      #  if difference > 0
      #    changed = true
      $("""table[rel="#{group}"] :checkbox""").each ->
        $this = $ this
        difference = +$this.prop('checked') - parseFloat($this.attr('data-initial'))
        group_balance -= difference * parseFloat($this.attr('data-value'))
        if difference > 0
          changed = true

      balance += group_balance

      # Update balance.
      currency = number_to_currency group_balance
      amount.html(currency).toggleClass 'negative', group_balance < 0

      # Move bar and balance.
      pixels = -Math.round(tanh(3 * group_balance / maximumDifference) * 150)
      width = Math.abs pixels

      # If at zero.
      if bar.width() == 0
        amount.animate left: amountLeft - pixels
        bar.css('background-color', if group_balance < 0 then '#f00' else '#000').animate
          left: Math.min(barLeft, barLeft - pixels)
          width: width
      # If going from negative to positive.
      else if group_balance > 0 && bar.position().left < barLeft
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
      else if group_balance < 0 && bar.position().left == barLeft
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

    submittable = false
    message = $ '#message'

    # Update message.
    if balance < 0
      message.html t('deficit')
    else if balance == 0
      if changed
        submittable = true
        message.html t('balanced')
      else
        message.html t('instructions')
    else
      if balance > 50000
        message.html t('big_surplus')
      else if changed
        submittable = true
        message.html t('nearly_balanced')
      else
        message.html t('surplus')
    message.animate {'background-color': if balance == 0 then '#666' else (if balance < 0 then '#f00' else '#000')}, 'slow'

    # @todo
    #$('#submit').animate({height: action, opacity: action}, 'slow')

    # Enable or disable identification form.
    if submittable
      enableForm()
    else
      disableForm()

  highlight = ($control, current) ->
    $tr = $control.parents 'tr'
    initial = parseFloat $control.attr('data-initial')
    value = parseFloat $control.attr('data-value')

    if current == initial
      $tr.find('.impact').css 'visibility', 'hidden'
      if $tr.hasClass 'selected'
        $tr.removeClass 'selected'
        $tr.find('td.description').animate 'background-color': '#fff', 'slow'
        $tr.find('td.highlight').animate 'background-color': '#ff9', 'slow'
    else
      $tr.find('.value').html number_to_currency(Math.abs(current - initial) * value)
      $tr.find('.key').html if current - initial < 0 then t('savings') else t('costs')
      $tr.find('.impact').css 'visibility', 'visible'
      unless $tr.hasClass 'selected'
        $tr.addClass 'selected'
        $tr.find('td').animate 'background-color': '#add5f7', 'fast'

  # Slider widget
  # @todo

  # On/off widget
  $('table :checkbox').each ->
    $this = $ this
    options =
      resizeContainer: false
      onChange: (input, checked) ->
        highlight input, +checked
        updateCategoryBalance input
        updateBalance()
    if $this.is ':checked'
      options.checkedLabel = t 'no'
      options.uncheckedLabel = t 'yes'
      options.labelOffClass = 'iPhoneCheckLabelOff reverse'
      options.labelOnClass = 'iPhoneCheckLabelOn reverse'
    else
      options.resizeContainer = false
      options.checkedLabel = t 'yes'
      options.uncheckedLabel = t 'no'
    $this.iphoneStyle options

  $('.minimum').click ->
    $this = $ this
    $widget = $this.parents '.widget'
    $widget.find(':checkbox').prop('checked', false).trigger 'change'
    # @todo
    #$slider = $widget.find '.slider'
    #$slider.slider 'value', $slider.attr('data-minimum')

  $('.maximum').click ->
    $this = $ this
    $widget = $this.parents '.widget'
    $widget.find(':checkbox').prop('checked', true).trigger 'change'
    # @todo
    #$slider = $widget.find '.slider'
    #$slider.slider 'value', $slider.attr('data-maximum')
