class TaxSimulator extends Simulator
  constructor: (@options = {}) ->
    super

    @colors = @options.colors ||
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

    $('#assessment input').blur ->
      # Reset to default value if custom value is invalid.
      $('#assessment input').val('') if customAssessment() <= 0

      # Need to update all numbers to match the new assessment.
      @update()

      $('table').find('input:first').each ->
        @updateSection($(this))

      # So far, only scalers have been implemented in "Taxes" mode.
      $('.widget-scaler').each ->
        $widget = $(this)
        $slider = $widget.find('.slider')

        # @see Simulator#updateQuestion
        difference = ($slider.slider('value') - $slider.data('initial')) * $slider.data('value')
        $widget.find('.value').html(SimulatorHelper.number_to_currency(Math.abs(difference) * scale(), strip_insignificant_zeros: true))

        # In case we display minimum and maximum values again:
        #$widget.find('.minimum.taxes').html(SimulatorHelper.number_to_currency(taxAmount($slider, $slider.data('minimum'))))
        #$widget.find('.maximum.taxes').html(SimulatorHelper.number_to_currency(taxAmount($slider, $slider.data('maximum'))))

        updateTip($slider, $slider.slider('value'))

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

  messages: ->
    en_US:
      surplus: 'You have decreased your tax dollars by {{number}}/month or {{percentage}}. This could result in a service level reduction.'
      balanced: 'Your budget is balanced.'
      deficit: 'You have increased your tax dollars by {{number}}/month or {{percentage}}. This could result in a service level enhancement.'
    fr_CA:
      surplus: 'Vos impôts diminueraient de {{number}} par mois, donc {{percentage}}. Il peut en résulter une réduction du niveau de service.'
      balanced: "Vous avez atteint l'équilibre."
      deficit: 'Vos impôts augmenteraient de {{number}} par mois, donc {{percentage}}. Cette augmentation peut se traduire par un niveau de service amélioré.'

  messageOptions: (net_balance) ->
    number: SimulatorHelper.number_to_currency(Math.abs(net_balance), strip_insignificant_zeros: true)
    percentage: SimulatorHelper.number_to_percentage(Math.abs(net_balance) / @options.tax_rate / scale() * 100, strip_insignificant_zeros: true)

  setMessage: (net_balance) ->
    super
    $('#reminder').toggleClass('hide', not @isChanged())

  scale: ->
    (@customAssessment() || @options.default_assessment) / 12.0 # monthly assessment period

  # @return [Integer] the participant's custom property assessment
  # @todo Non-English participants may enter a comma as the decimal mark.
  customAssessment: ->
    parseFloat($('#assessment input').val().replace(/[^0-9.]/, '')) if $('#assessment input').length

  # @return [Float] the impact of a single change to the budget
  taxAmount: ($slider, number) ->
    parseFloat($slider.data('value')) * parseFloat(number) * scale()

  # @return [String] content for the tip on a scaler
  tipScaler: ($slider, number) ->
    SimulatorHelper.number_to_currency(@taxAmount($slider, number), strip_insignificant_zeros: true)
