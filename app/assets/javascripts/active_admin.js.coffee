//= require active_admin/base
//= require bootstrap
//= require swfobject
//= require jquery.clippy
//= require i18n

$ ->
  $('[rel="tooltip"]').tooltip()

  # URL with token.
  $(document).on 'mouseup', '.url-with-token', ->
    $(this).select()

  $('.clippy').each ->
    $this = $ this
    $this.clippy
      clippy_path: '/assets/clippy.swf'
      flashvars:
        args: $this.data 'tooltip'

  window.clippyCopiedCallback = (args) ->
    $('#' + args).attr('data-original-title', t('copied_hint')).tooltip('show').attr('data-original-title', t('copy_hint'))

  # Sortable sections and questions.
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

  toggle_mode = ->
    value = $('input[name="questionnaire[mode]"]:checked').val()
    $("#questionnaire_default_assessment_input,
       #questionnaire_tax_rate_input"
    ).toggle(value == 'taxes')

  $('input[name="questionnaire[mode]"]').change toggle_mode
  toggle_mode()

  # Display the appropriate options for the selected widget.
  setup_fieldset = (i) ->
    widget = $("#section_questions_attributes_#{i}_widget")

    toggle_options = ->
      value = widget.val()
      $("#section_questions_attributes_#{i}_options_as_list_input"
      ).toggle(value in ['checkboxes', 'radio', 'select'])

      $("#section_questions_attributes_#{i}_default_value_input"
      ).toggle(value in ['checkbox', 'onoff', 'slider', 'scaler'])

      $("#section_questions_attributes_#{i}_unit_amount_input"
      ).toggle(value in ['onoff', 'slider', 'scaler'])

      $("#section_questions_attributes_#{i}_minimum_units_input,
         #section_questions_attributes_#{i}_maximum_units_input,
         #section_questions_attributes_#{i}_step_input"
      ).toggle(value in ['slider', 'scaler'])

      $("#section_questions_attributes_#{i}_unit_name_input"
      ).toggle(value == 'slider')

      $("#section_questions_attributes_#{i}_size_input,
         #section_questions_attributes_#{i}_maxlength_input,
         #section_questions_attributes_#{i}_placeholder_input"
      ).toggle(value == 'text')

      $("#section_questions_attributes_#{i}_rows_input,
         #section_questions_attributes_#{i}_cols_input"
      ).toggle(value == 'textarea')

    widget.change toggle_options
    toggle_options()

  $('.has_many.questions .button:last').click ->
    setup_fieldset $('.has_many.questions fieldset:last [id]').attr('id').match(/\d+/)[0]

  $('.has_many.questions fieldset').each setup_fieldset

# Dashboard charts.
window.draw = (chart_type, id, headers, rows, options) ->
  # https://developers.google.com/chart/interactive/docs/drawing_charts
  google.setOnLoadCallback ->
    data = new google.visualization.DataTable()
    data.addColumn if chart_type is 'LineChart' then 'date' else 'string'
    data.addColumn('number', header) for header in headers
    data.addColumn({type: 'string', role: 'tooltip'}) if options.tooltip?
    data.addRows(rows)
    new google.visualization.drawChart
      chartType: chart_type
      containerId: id
      dataTable: data
      options: options
