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
    big_surplus: "Your budget has a surplus of %{number}. Add more activities to approach a balanced budget."
    surplus: 'Your budget has a surplus of %{number}. You may add more activities.'
    nearly_balanced: 'Your budget has a surplus of %{number}. You may <a href="#identification">submit</a> your choices or continue making changes.'
    balanced: 'Your budget is balanced. You may <a href="#identification">submit</a> your choices or continue making changes.'
    deficit: 'Your budget is in deficit (%{number}). Cut activities to balance the budget.'
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
    big_surplus: "Votre budget montre un surplus de %{number}. Ajouter de nouvelles activités afin de vous rapprocher de l'équilibre budgétaire."
    surplus: 'Votre budget montre un surplus de %{number}. Vous pouvez ajouter de nouvelles activités.'
    nearly_balanced: "Votre budget montre un surplus de %{number}. Vous pouvez <a href=\"#identification\">soumettre</a> vos choix ou continuer l'exercise."
    balanced: "Votre budget est équilibré. Vous pouvez <a href=\"#identification\">soumettre</a> vos choix ou continuer l'exercise."
    deficit: 'Votre budget est en déficit (%{number}). Renoncez à des activités pour équilibrer le budget.'

window.t = (string, args = {}) ->
  current_locale = args.locale or window.locale or 'en'
  string = I18n[current_locale][string] or string
  string = string.replace ///%\{#{key}\}///g, value for key, value of args
  string
