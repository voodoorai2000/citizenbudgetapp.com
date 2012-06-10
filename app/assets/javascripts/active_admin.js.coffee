//= require active_admin/base
$ ->
  $('.has_many.questions fieldset').each (i, x) ->
    widget = $("#section_questions_attributes_#{i}_widget")
    toggle_options = ->
      $("#section_questions_attributes_#{i}_options_input"
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
  # @todo default_value should be checkbox if onoff or checkbox
