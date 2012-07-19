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
    gains: 'Gains:'
    losses: 'Losses:'
    savings: 'Savings:'
    costs: 'Costs:'
    instructions: 'Change an activity to start.'
    surplus: """Your budget has a surplus of %{number}. If you're finished <a href="#identification">submit your choices</a>. Otherwise, <b>add activities or cut revenues to balance the budget</b>."""
    balanced: """<b>Your budget is balanced!</b> If you're finished <a href="#identification">submit your choices</a>."""
    deficit: 'Your budget is in deficit (%{number}). <b>Cut activities or add revenues to balance the budget.</b>'
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
    gains: 'Gains :'
    losses: 'Pertes :'
    savings: 'Épargnes :'
    costs: 'Coûts :'
    instructions: 'Modifiez une activité pour commencer.'
    surplus: """Votre budget montre un surplus de %{number}. Vous pouvez <a href="#identification">soumettre vos choix</a>. Sinon, <b>ajoutez des activités ou reduisez les revenus pour équilibrer le budget</b>."""
    balanced: """<b>Vous avez atteint l'équilibre!</b> Si vous avez fini, <a href="#identification">soumettez vos choix</a>."""
    deficit: 'Votre budget est en déficit (%{number}). <b>Renoncez à des activités ou augmentez les revenus pour équilibrer le budget.</b>'
    copy_hint: 'copier dans le presse papier'
    copied_hint: 'copié!'

window.t = (string, args = {}) ->
  current_locale = args.locale or window.locale or 'en'
  string = I18n[current_locale][string] or string
  string = string.replace ///%\{#{key}\}///g, value for key, value of args
  string
