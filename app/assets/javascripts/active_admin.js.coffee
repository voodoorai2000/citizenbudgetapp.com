//= require active_admin/base
//= require bootstrap.min

I18n =
  en:
    overlay_title: 'Sample overlay'
    overlay_text: 'This is where the explanatory text would appear.'
  fr:
    overlay_title: 'Échantillon de bulle'
    overlay_text: 'Votre texte apparaîtrait ici.'

window.t = (string, args = {}) ->
  current_locale = args.locale or window.locale or 'en'
  string = I18n[current_locale][string] or string
  string = string.replace ///%\{#{key}\}///g, value for key, value of args
  string

$ ->
  setup_fieldset = (i) ->
    widget = $("#section_questions_attributes_#{i}_widget")

    # @todo default_value should be checkbox if onoff or checkbox

    toggle_options = ->
      $("#section_questions_attributes_#{i}_options_as_list_input"
      ).toggle(widget.val() in ['radio', 'select'])
      widget.val() in ['checkbox', 'onoff']
      $("#section_questions_attributes_#{i}_default_value_input,
         #section_questions_attributes_#{i}_unit_amount_input"
      ).toggle(widget.val() in ['checkbox', 'onoff', 'radio', 'select', 'slider'])
      $("#section_questions_attributes_#{i}_minimum_units_input,
         #section_questions_attributes_#{i}_maximum_units_input,
         #section_questions_attributes_#{i}_step_input,
         #section_questions_attributes_#{i}_unit_name_input"
      ).toggle(widget.val() == 'slider')

    widget.change toggle_options
    toggle_options()

  $('.has_many.questions .button:last').click ->
    setup_fieldset $('.has_many.questions fieldset:last [id]').attr('id').match(/\d+/)[0]

  $('.has_many.questions fieldset').each setup_fieldset
