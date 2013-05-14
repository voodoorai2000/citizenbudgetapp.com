I18n =
  en_US:
    overlay_title: 'Sample overlay'
    overlay_text: 'This is where the explanatory text would appear.'
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
    copy_hint: 'copy to clipboard'
    copied_hint: 'copied!'
  fr_CA:
    overlay_title: 'Échantillon de bulle'
    overlay_text: 'Votre texte apparaîtrait ici.'
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
    copy_hint: 'copier dans le presse papier'
    copied_hint: 'copié!'

window.t = (string, args = {}) ->
  current_locale = args.locale or window.locale or 'en'
  string = I18n[current_locale][string] or string
  string = Mustache.render string, args
  string

window.translationExists = (string, args = {}) ->
  current_locale = args.locale or window.locale or 'en'
  I18n[current_locale][string]?
