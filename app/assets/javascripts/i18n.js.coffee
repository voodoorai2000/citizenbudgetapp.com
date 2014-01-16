window.I18n =
  en_US:
    currency_delimiter: ','
    currency_format: '{{unit}}{{number}}'
    currency_separator: '.'
    currency_unit: '$'
    percentage_format: '{{number}}{{symbol}}'
    percentage_symbol: '%'
    assessment_period: '{{number}}/month'
    instructions: 'Change an activity to start'
    copy_hint: 'copy to clipboard'
    copied_hint: 'copied!'
  fr_CA:
    currency_delimiter: ' '
    currency_format: '{{number}} {{unit}}'
    currency_separator: ','
    currency_unit: '$'
    percentage_format: '{{number}} {{symbol}}'
    percentage_symbol: '%'
    assessment_period: '{{number}} par mois'
    instructions: 'Modifiez une activité pour commencer'
    copy_hint: 'copier dans le presse papier'
    copied_hint: 'copié!'
  es_ES:
    currency_delimiter: ' '
    currency_format: '{{number}} {{unit}}'
    currency_separator: ','
    currency_unit: '€'
    percentage_format: '{{number}} {{symbol}}'
    percentage_symbol: '%'
    assessment_period: '{{number}}/mes'
    instructions: 'Cambia una actividad para empezar'
    copy_hint: 'copiar al portapapeles'
    copied_hint: '¡copiado!'

window.t = (string, args = {}, dict = I18n) ->
  current_locale = args.locale or window.locale or 'en'
  string = dict[current_locale][string] or string
  string = Mustache.render string, args
  string
