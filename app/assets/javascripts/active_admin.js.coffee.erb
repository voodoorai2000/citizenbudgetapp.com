//= require active_admin/base
//= require bootstrap.min
//= require i18n

$ ->
  $('.sortable').sortable
    axis: 'y'
    cursor: 'move'
    handle: 'i'
    update: (event, ui) ->
      $target = $ event.target
      $.ajax
        type: 'POST'
        url: location.href + '/sort'
        data: $target.sortable 'serialize'
      .done (request) ->
        $target.effect 'highlight'

  # Display the appropriate options for the selected widget.
  setup_fieldset = (i) ->
    widget = $("#section_questions_attributes_#{i}_widget")

    # @todo default_value should be rendered as a checkbox if widget is onoff or checkbox

    toggle_options = ->
      $("#section_questions_attributes_#{i}_options_as_list_input"
      ).toggle(widget.val() in ['checkboxes', 'radio', 'select'])

      $("#section_questions_attributes_#{i}_default_value_input,
         #section_questions_attributes_#{i}_unit_amount_input"
      ).toggle(widget.val() in ['checkbox', 'onoff', 'slider'])

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
