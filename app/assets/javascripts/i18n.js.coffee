I18n =
  en:
    overlay_title: 'Sample overlay'
    overlay_text: 'This is where the explanatory text would appear.'
    yes: 'YES'
    no: 'NO'
    currency_delimiter: ','
    currency_format: '{{unit}}{{number}}'
    currency_unit: '$'
    savings: 'Savings:'
    costs: 'Costs:'
    instructions: 'Change an activity to start.'
    surplus: 'Your budget has a surplus of %{number}. <b>Add more activities to approach a balanced budget.</b>'
    nearly_balanced: 'Your budget has a surplus of %{number}.'
    balanced: 'Your budget is balanced.'
    deficit: 'Your budget is in deficit (%{number}). <b>Cut activities to balance the budget.</b>'
  fr_CA:
    overlay_title: 'Échantillon de bulle'
    overlay_text: 'Votre texte apparaîtrait ici.'
    yes: 'OUI'
    no: 'NON'
    currency_delimiter: ' '
    currency_format: '{{number}} {{unit}}'
    currency_unit: '$'
    savings: 'Épargnes :'
    costs: 'Coûts :'
    instructions: 'Modifiez une activité pour commencer.'
    surplus: 'Votre budget montre un surplus de %{number}. <b>Ajouter des activités pour équilibrer le budget.</b>'
    nearly_balanced: "Votre budget montre un surplus de %{number}."
    balanced: "Votre budget est équilibré."
    deficit: 'Votre budget est en déficit (%{number}). <b>Renoncez à des activités pour équilibrer le budget.</b>'

window.t = (string, args = {}) ->
  current_locale = args.locale or window.locale or 'en'
  string = I18n[current_locale][string] or string
  string = string.replace ///%\{#{key}\}///g, value for key, value of args
  string
