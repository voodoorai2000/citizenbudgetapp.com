# Respondents can submit as long as the budget is close enough to balance.
class window.DeviationSimulator extends window.Simulator
  canSubmit: ->
    super and Math.abs(@net_balance()) <= @options.maximum_deviation

  messages: ->
    if @scope.find('[data-revenue]').length
      en_US:
        large_surplus: 'Your budget is off balance by {{number}}. <b>Add activities or cut revenues to balance the budget</b>.'
        surplus: """Your budget has a surplus of {{number}}. If you're finished, <a href="#identification">submit your choices</a>. Otherwise, <b>add activities or cut revenues to balance the budget</b>."""
        balanced: """<b>Your budget is balanced!</b> If you're finished, <a href="#identification">submit your choices</a>."""
        deficit: """Your budget is in deficit ({{number}}). If you're finished, <a href="#identification">submit your choices</a>. Otherwise, <b>cut activities or add revenues to balance the budget</b>."""
        large_deficit: 'Your budget is off balance by {{number}}. <b>Cut activities or add revenues to balance the budget</b>.'
      fr_CA:
        large_surplus: 'Votre budget est déséquilibré de {{number}}. <b>Ajoutez des activités ou reduisez les revenus pour équilibrer le budget</b>.'
        surplus: """Votre budget montre un surplus de {{number}}. Vous pouvez <a href="#identification">soumettre vos choix</a>. Sinon, <b>ajoutez des activités ou reduisez les revenus pour équilibrer le budget</b>."""
        balanced: """<b>Vous avez atteint l'équilibre!</b> Si vous avez fini, <a href="#identification">soumettez vos choix</a>."""
        deficit: """Votre budget est en déficit ({{number}}). Vous pouvez <a href="#identification">soumettre vos choix</a>. Sinon, <b>renoncez à des activités ou augmentez les revenus pour équilibrer le budget</b>."""
        large_deficit: 'Votre budget est déséquilibré de {{number}}. <b>Renoncez à des activités ou augmentez les revenus pour équilibrer le budget</b>.'
      es_ES:
        large_surplus: 'Su presupuesto está desequilibrado por {{number}}. <b>Añada actividades o reduzca los ingresos para equilibrar el presupuesto</b>.'
        surplus: """Su presupuesto tiene un superávit de {{number}}. Si ha terminado, <a href="#identification">envie sus respuetas</a>. De lo contrario, <b>Añada actividades o reduzca los ingresos para equilibrar el presupuesto</b>."""
        balanced: """<b>¡Su presupuesto está equilibrado!</b> Si ha terminado, <a href="#identification">envie sus respuetas</a>."""
        deficit: """Su presupuesto está en déficit ({{number}}). Si ha terminado, <a href="#identification">envie sus respuetas</a>. De lo contrario, <b>reduzca actividades o añada ingresos para equilibrar el presupuesto</b>."""
        large_deficit: 'Su presupuesto está desequilibrado por {{number}}. <b>Reduzca actividades o añada ingresos para equilibrar el presupuesto</b>.'
    else
      en_US:
        large_surplus: 'Your budget is off balance by {{number}}. <b>Add activities to balance the budget</b>.'
        surplus: """Your budget has a surplus of {{number}}. If you're finished, <a href="#identification">submit your choices</a>. Otherwise, <b>add activities to balance the budget</b>."""
        balanced: """<b>Your budget is balanced!</b> If you're finished, <a href="#identification">submit your choices</a>."""
        deficit: """Your budget is in deficit ({{number}}). If you're finished, <a href="#identification">submit your choices</a>. Otherwise, <b>cut activities to balance the budget</b>."""
        large_deficit: 'Your budget is off balance by {{number}}. <b>Cut activities to balance the budget</b>.'
      fr_CA:
        large_surplus: 'Votre budget est déséquilibré de {{number}}. <b>Ajoutez des activités pour équilibrer le budget</b>.'
        surplus: """Votre budget montre un surplus de {{number}}. Vous pouvez <a href="#identification">soumettre vos choix</a>. Sinon, <b>ajoutez des activités pour équilibrer le budget</b>."""
        balanced: """<b>Vous avez atteint l'équilibre!</b> Si vous avez fini, <a href="#identification">soumettez vos choix</a>."""
        deficit: """Votre budget est en déficit ({{number}}). Vous pouvez <a href="#identification">soumettre vos choix</a>. Sinon, <b>renoncez à des activités pour équilibrer le budget</b>."""
        large_deficit: 'Votre budget est déséquilibré de {{number}}. <b>Renoncez à des activités pour équilibrer le budget</b>.'
      es_ES:
        large_surplus: 'Su presupuesto está desequilibrado por {{number}}. <b>Añada actividades para equilibrar el presupuesto</b>.'
        surplus: """Su presupuesto tiene un superávit de {{number}}. Si ha terminado, <a href="#identification">envie sus respuetas</a>. De lo contrario, <b>Añada actividades para equilibrar el presupuesto</b>."""
        balanced: """<b>¡Su presupuesto está equilibrado!</b> Si ha terminado, <a href="#identification">envie sus respuetas</a>."""
        deficit: """Su presupuesto está en déficit ({{number}}). Si ha terminado, <a href="#identification">envie sus respuetas</a>. De lo contrario, <b>reduzca actividades para equilibrar el presupuesto</b>."""
        large_deficit: 'Su presupuesto está desequilibrado por {{number}}. <b>Reduzca actividades para equilibrar el presupuesto</b>.'

  message: (net_balance, options) ->
    if net_balance == 0
      if @isChanged()
        t('balanced')
      else
        @instructions
    else if Math.abs(net_balance) <= @options.maximum_deviation
      if net_balance < 0
        t('deficit', options)
      else
        t('surplus', options)
    else
      if net_balance < 0
        t('large_deficit', options)
      else
        t('large_surplus', options)
