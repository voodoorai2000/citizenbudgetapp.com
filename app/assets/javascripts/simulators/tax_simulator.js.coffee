class window.TaxSimulator extends window.Simulator
  constructor: (@options = {}) ->
    super

    # Override to not toggle tip at minimum value.
    window.updateTip = ($slider, value) ->
      content = self.tipSlider($slider, value)
      $slider.find('.tip-content').html(content) if content

    self = this
    $('#assessment input').bind 'keydown keypress keyup', (event) ->
      if event.keyCode == 13
        event.preventDefault()
        $(this).blur()
    $('#assessment input').blur ->
      # Reset to default value if custom value is invalid.
      $('#assessment input').val('') if self.customAssessment() <= 0

      # Need to update all numbers to match the new assessment.
      self.update()

      self.scope.find('input:first').each ->
        self.updateSection($(this))

      # So far, only scalers have been implemented in "Taxes" mode.
      self.scope.find('.widget-scaler').each ->
        $widget = $(this)
        $slider = $widget.find('.slider')

        # @see Simulator#updateQuestion
        difference = ($slider.slider('value') - $slider.data('initial')) * $slider.data('value')
        $widget.find('.value').html(SimulatorHelper.number_to_currency(Math.abs(difference) * self.scale(), strip_insignificant_zeros: true))

        # In case we display minimum and maximum values again:
        # $widget.find('.minimum.taxes').html(SimulatorHelper.number_to_currency(taxAmount($slider, $slider.data('minimum'))))
        # $widget.find('.maximum.taxes').html(SimulatorHelper.number_to_currency(taxAmount($slider, $slider.data('maximum'))))

        updateTip($slider, $slider.slider('value'))

      self.scope.find('.control-static').each ->
        $widget = $(this)
        content = t 'assessment_period', number: self.tipSlider($widget, 1.0)
        $widget.html(content)

  colorSetting: ->
    # XXX hack to read CSS rule.
    $element = $('<tr class="selected"><td></td></tr>').appendTo('body')
    change_background_color = $element.find('td').css('background-color')
    $element.remove()

    # The colors of the single solid bar in the graph.
    bar:
      positive: '#000'
      negative: '#f00'
    # The colors of the status message in the navigation.
    message:
      background:
        positive: '#000'
        neutral: $('#message').css('background-color') # administrators can override the CSS
        negative: '#000'
      foreground:
        positive: '#fff'
        neutral: '#fff'
        negative: '#fff'
    # The colors of the budgetary values in the section navigation.
    section:
      positive: '#000'
      negative: '#f00'
    # The colors of the question and its budgetary values.
    question:
      positive: '#000'
      negative: '#000'
      description: '#fff'
      highlight: '#ff9'
      selected: change_background_color

  strings: ->
    en_US:
      gains: 'Increase:'
      losses: 'Decrease:'
      savings: 'Decrease:'
      costs: 'Increase:'
    fr_CA:
      gains: 'Augmentation :'
      losses: 'Diminution :'
      savings: 'Diminution :'
      costs: 'Augmentation :'
    es_ES:
      gains: 'Subir:'
      losses: 'Bajar:'
      savings: 'Bajar:'
      costs: 'Subir:'
  messages: ->
    en_US:
      surplus: 'You have decreased your tax dollars by {{number}}/month or {{percentage}}. This could result in a service level reduction.'
      balanced: 'Your budget is balanced.'
      deficit: 'You have increased your tax dollars by {{number}}/month or {{percentage}}. This could result in a service level enhancement.'
    fr_CA:
      surplus: 'Vos impôts diminueraient de {{number}} par mois, donc {{percentage}}. Il peut en résulter une réduction du niveau de service.'
      balanced: "Vous avez atteint l'équilibre."
      deficit: 'Vos impôts augmenteraient de {{number}} par mois, donc {{percentage}}. Cette augmentation peut se traduire par un niveau de service amélioré.'
    es_ES:
      surplus: 'Ha bajado sus impuestos a {{number}}/month o {{percentage}}. Esto podría resultar en una reducción de nivel de servicios.'
      balanced: 'Su presupuesto está equilibrado.'
      deficit: 'Ha subido sus impuestos a {{number}}/month o {{percentage}}. Esto podría resultar en una mejora de nivel de servicios.'

  messageOptions: (net_balance) ->
    number: SimulatorHelper.number_to_currency(Math.abs(net_balance), strip_insignificant_zeros: true)
    percentage: SimulatorHelper.number_to_percentage(Math.abs(net_balance) / @options.tax_rate / @scale() * 100, strip_insignificant_zeros: true)

  setMessage: (net_balance) ->
    super
    $('#reminder').toggleClass('hide', not @isChanged())

  scale: ->
    (@customAssessment() || @options.default_assessment) / 12.0 # monthly assessment period

  # @return [Integer] the participant's custom property assessment
  # @todo Non-English participants may enter a comma as the decimal mark.
  customAssessment: ->
    parseFloat($('#assessment input').val().replace(/[^0-9.]/g, '')) if $('#assessment input').length

  # @return [Float] the impact of a single change to the budget
  taxAmount: ($widget, number) ->
    parseFloat($widget.data('value')) * parseFloat(number) * @scale()

  # @return [String] content for the tip on a scaler
  tipScaler: ($widget, number) ->
    SimulatorHelper.number_to_currency(Math.abs(@taxAmount($widget, number)), strip_insignificant_zeros: true)
