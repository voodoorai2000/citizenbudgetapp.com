I18n =
  en_US:
    overlay_title: 'Sample overlay'
    overlay_text: 'This is where the explanatory text would appear.'
    yes: 'YES'
    no: 'NO'
    currency_delimiter: ','
    currency_format: '{{unit}}{{number}}'
    currency_separator: '.'
    currency_unit: '$'
    percentage_format: '{{number}}{{symbol}}'
    percentage_symbol: '%'
    services_gains: 'Gains:'
    services_losses: 'Losses:'
    taxes_gains: 'Increase:'
    taxes_losses: 'Decrease:'
    services_savings: 'Savings:'
    services_costs: 'Costs:'
    taxes_savings: 'Decrease:'
    taxes_costs: 'Increase:'
    instructions: 'Change an activity to start'
    services_surplus: """Your budget has a surplus of %{number}. If you're finished, <a href="#identification">submit your choices</a>. Otherwise, <b>add activities or cut revenues to balance the budget</b>."""
    services_balanced: """<b>Your budget is balanced!</b> If you're finished, <a href="#identification">submit your choices</a>."""
    services_deficit: 'Your budget is in deficit (%{number}). <b>Cut activities or add revenues to balance the budget.</b>'
    taxes_surplus: 'You have decreased your tax dollars by %{number}/month. This could result in a service level reduction.'
    taxes_balanced: 'Your budget is balanced.'
    taxes_deficit: 'You have increased your tax dollars by %{number}/month. This could result in a service level enhancement.'
    copy_hint: 'copy to clipboard'
    copied_hint: 'copied!'
  fr_CA:
    overlay_title: 'Échantillon de bulle'
    overlay_text: 'Votre texte apparaîtrait ici.'
    yes: 'OUI'
    no: 'NON'
    currency_delimiter: ' '
    currency_format: '{{number}} {{unit}}'
    currency_separator: ','
    currency_unit: '$'
    percentage_format: '{{number}} {{symbol}}'
    percentage_symbol: '%'
    services_gains: 'Gains :'
    services_losses: 'Pertes :'
    taxes_gains: 'Augmentation :'
    taxes_losses: 'Diminution :'
    services_savings: 'Épargnes :'
    services_costs: 'Coûts :'
    taxes_savings: 'Diminution :'
    taxes_costs: 'Augmentation :'
    instructions: 'Modifiez une activité pour commencer'
    services_surplus: """Votre budget montre un surplus de %{number}. Vous pouvez <a href="#identification">soumettre vos choix</a>. Sinon, <b>ajoutez des activités ou reduisez les revenus pour équilibrer le budget</b>."""
    services_balanced: """<b>Vous avez atteint l'équilibre!</b> Si vous avez fini, <a href="#identification">soumettez vos choix</a>."""
    services_deficit: 'Votre budget est en déficit (%{number}). <b>Renoncez à des activités ou augmentez les revenus pour équilibrer le budget.</b>'
    taxes_surplus: 'Vos impôts diminueraient de %{number} par mois. Il peut en résulter une réduction du niveau de service.'
    taxes_balanced: "Vous avez atteint l'équilibre."
    taxes_deficit: 'Vos impôts augmenteraient de %{number} par mois. Cette augmentation peut se traduire par un niveau de service amélioré.'
    copy_hint: 'copier dans le presse papier'
    copied_hint: 'copié!'

window.t = (string, args = {}) ->
  current_locale = args.locale or window.locale or 'en'
  string = I18n[current_locale][string] or string
  string = string.replace ///%\{#{key}\}///g, value for key, value of args
  string

window.translationExists = (string, args = {}) ->
  current_locale = args.locale or window.locale or 'en'
  I18n[current_locale][string]?
