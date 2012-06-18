# encoding: utf-8

# --------------------------------------------------------------------------------------------------
# Please note: If you're subclassing Formtastic::FormBuilder, Formtastic uses
# class_attribute for these configuration attributes instead of the deprecated
# class_inheritable_attribute. The behaviour is slightly different with subclasses (especially
# around attributes with Hash or Array) values, so make sure you understand what's happening.
# See the documentation for class_attribute in ActiveSupport for more information.
# --------------------------------------------------------------------------------------------------

# Set the default text field size when input is a string. Default is nil.
# Formtastic::FormBuilder.default_text_field_size = 50

# Set the default text area height when input is a text. Default is 20.
# Formtastic::FormBuilder.default_text_area_height = 5

# Set the default text area width when input is a text. Default is nil.
# Formtastic::FormBuilder.default_text_area_width = 50

# Should all fields be considered "required" by default?
# Defaults to true.
# Formtastic::FormBuilder.all_fields_required_by_default = true

# Should select fields have a blank option/prompt by default?
# Defaults to true.
# Formtastic::FormBuilder.include_blank_for_select_by_default = true

# Set the string that will be appended to the labels/fieldsets which are required
# It accepts string or procs and the default is a localized version of
# '<abbr title="required">*</abbr>'. In other words, if you configure formtastic.required
# in your locale, it will replace the abbr title properly. But if you don't want to use
# abbr tag, you can simply give a string as below
# Formtastic::FormBuilder.required_string = "(required)"

# Set the string that will be appended to the labels/fieldsets which are optional
# Defaults to an empty string ("") and also accepts procs (see required_string above)
# Formtastic::FormBuilder.optional_string = "(optional)"

# Set the way inline errors will be displayed.
# Defaults to :sentence, valid options are :sentence, :list, :first and :none
# Formtastic::FormBuilder.inline_errors = :sentence
# Formtastic uses the following classes as default for hints, inline_errors and error list

# If you override the class here, please ensure to override it in your stylesheets as well
# Formtastic::FormBuilder.default_hint_class = "inline-hints"
# Formtastic::FormBuilder.default_inline_error_class = "inline-errors"
# Formtastic::FormBuilder.default_error_list_class = "errors"

# Set the method to call on label text to transform or format it for human-friendly
# reading when formtastic is used without object. Defaults to :humanize.
# Formtastic::FormBuilder.label_str_method = :humanize

# Set the array of methods to try calling on parent objects in :select and :radio inputs
# for the text inside each @<option>@ tag or alongside each radio @<input>@. The first method
# that is found on the object will be used.
# Defaults to ["to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]
# Formtastic::FormBuilder.collection_label_methods = [
#   "to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]

# Additionally, you can customize the order for specific types of inputs.
# This is configured on a type basis and if a type is not found it will
# fall back to the default order as defined by #inline_order
# Formtastic::FormBuilder.custom_inline_order[:checkbox] = [:errors, :hints, :input]
# Formtastic::FormBuilder.custom_inline_order[:select] = [:hints, :input, :errors]

# Specifies if labels/hints for input fields automatically be looked up using I18n.
# Default value: true. Overridden for specific fields by setting value to true,
# i.e. :label => true, or :hint => true (or opposite depending on initialized value)
# Formtastic::FormBuilder.i18n_lookups_by_default = false

# Specifies if I18n lookups of the default I18n Localizer should be cached to improve performance.
# Defaults to false.
# Formtastic::FormBuilder.i18n_cache_lookups = true

# Specifies the class to use for localization lookups. You can create your own
# class and use it instead by subclassing Formtastic::Localizer (which is the default).
# Formtastic::FormBuilder.i18n_localizer = MyOwnLocalizer

# https://github.com/mjbellantoni/formtastic-bootstrap#major-difference-in-behavior
module Formtastic
  module Actions
    module Base
      # Remove:
      #     template.content_tag(:li, ...)
      def wrapper(&block)
        template.capture(&block)
      end
    end

    module Buttonish
      # Add class.
      def extra_button_html_options
        {type: method, class: 'btn btn-primary'}
      end
    end
  end

  module Inputs
    module Base
      # The original method is utter nonsense.
      def label_html_options
        {for: input_html_options[:id], class: ['control-label']}
      end

      # Add:
      #     opts[:class] << "control-group"
      #
      # Remove:
      #     opts[:class] << as
      #     opts[:class] << "input"
      #     opts[:class] << "optional" if optional?
      #     opts[:class] << "required" if required?
      #     opts[:class] << "autofocus" if autofocus?
      def wrapper_html_options
        opts = (options[:wrapper_html] || {}).dup
        opts[:class] =
          case opts[:class]
          when Array
            opts[:class].dup
          when nil
            []
          else
            [opts[:class].to_s]
          end
        opts[:class] << "control-group"
        opts[:class] << "error" if errors?
        opts[:class] = opts[:class].join(' ')

        opts[:id] ||= wrapper_dom_id

        opts
      end

      # Change entirely.
      def input_wrapping(&block)
        template.content_tag(:div,
          template.capture(&block),
          wrapper_html_options
        )
      end

      module Numeric
        # Replace method.
        def wrapper_html_options
          super
        end
      end

      module Stringish
        # Replace method.
        def wrapper_html_options
          super
        end

        def to_html
          input_wrapping do
            label_html << template.content_tag(:div,
              [builder.text_field(method, input_html_options), error_html, hint_html].join("\n").html_safe,
              class: 'controls'
            )
          end
        end
      end
    end

    class BooleanInput
      # Simplify method.
      def label_html_options
        {for: input_html_options[:id], class: ['checkbox']}
      end

      def to_html
        input_wrapping do
          hidden_field_html << template.content_tag(:div,
            [label_with_nested_checkbox, error_html, hint_html].join("\n").html_safe,
            class: 'controls'
          )
        end
      end
    end

    class EmailInput
      def to_html
        input_wrapping do
          label_html << template.content_tag(:div,
            [builder.email_field(method, input_html_options), error_html, hint_html].join("\n").html_safe,
            class: 'controls'
          )
        end
      end
    end

    class RadioInput
      # Cut most of the wrappers.
      def to_html
        input_wrapping do
          label_html << template.content_tag(:div,
            collection.map { |choice|
              choice_html(choice)
            }.join("\n").html_safe,
            class: 'controls'
          )
        end
      end

      # Add class.
      def choice_html(choice)
        template.content_tag(:label,
          builder.radio_button(input_name, choice_value(choice), input_html_options.merge(choice_html_options(choice)).merge(:required => false)) <<
          choice_label(choice),
          label_html_options.merge(:for => choice_input_dom_id(choice), :class => 'radio inline')
        )
      end
    end

    class NumberInput
      def to_html
        input_wrapping do
          label_html << template.content_tag(:div,
            [builder.number_field(method, input_html_options), error_html, hint_html].join("\n").html_safe,
            class: 'controls'
          )
        end
      end
    end

    class TextInput
      def to_html
        input_wrapping do
          label_html << template.content_tag(:div,
            [builder.text_area(method, input_html_options), error_html, hint_html].join("\n").html_safe,
            class: 'controls'
          )
        end
      end
    end
  end
end

class CustomBuilder < Formtastic::FormBuilder
  default_hint_class = 'help-inline'
  default_inline_error_class = 'help-inline'

  # Remove:
  #     template.content_tag(:span, ...)
  def field_set_legend(html_options)
    legend  = (html_options[:name] || '').to_s
    legend %= parent_child_index(html_options[:parent]) if html_options[:parent]
    legend  = template.content_tag(:legend, Formtastic::Util.html_safe(legend)) unless legend.blank?
    legend
  end

  # Remove:
  #     template.content_tag(:ol, ...)
  def field_set_and_list_wrapping(*args, &block) #:nodoc:
    contents = args.last.is_a?(::Hash) ? '' : args.pop.flatten
    html_options = args.extract_options!

    if block_given?
      contents = if template.respond_to?(:is_haml?) && template.is_haml?
        template.capture_haml(&block)
      else
        template.capture(&block)
      end
    end

    # Ruby 1.9: String#to_s behavior changed, need to make an explicit join.
    contents = contents.join if contents.respond_to?(:join)

    legend = field_set_legend(html_options)
    fieldset = template.content_tag(:fieldset,
      Formtastic::Util.html_safe(legend) << Formtastic::Util.html_safe(contents),
      html_options.except(:builder, :parent, :name)
    )

    fieldset
  end

  # Remove:
  #     html_options[:class] ||= "inputs"
  #     out = template.content_tag(:li, out, :class => "input") if wrap_it
  def inputs(*args, &block)
    wrap_it = @already_in_an_inputs_block ? true : false
    @already_in_an_inputs_block = true

    title = field_set_title_from_args(*args)
    html_options = args.extract_options!
    html_options[:name] = title

    out = begin
      if html_options[:for] # Nested form
        inputs_for_nested_attributes(*(args << html_options), &block)
      elsif block_given?
        field_set_and_list_wrapping(*(args << html_options), &block)
      else
        legend = args.shift if args.first.is_a?(::String)
        args = default_columns_for_object if @object && args.empty?
        contents = fieldset_contents_from_column_list(args)
        args.unshift(legend) if legend.present?
        field_set_and_list_wrapping(*((args << html_options) << contents))
      end
    end

    @already_in_an_inputs_block = wrap_it
    out
  end

  # Change:
  #     html_options[:class] ||= "actions"
  def actions(*args, &block)
    html_options = args.extract_options!
    html_options[:class] ||= "form-actions"

    if block_given?
      field_set_and_list_wrapping(html_options, &block)
    else
      args = default_actions if args.empty?
      contents = args.map { |action_name| action(action_name) }
      field_set_and_list_wrapping(html_options, contents)
    end
  end
end

# You can add custom inputs or override parts of Formtastic by subclassing Formtastic::FormBuilder and
# specifying that class here.  Defaults to Formtastic::FormBuilder.
Formtastic::Helpers::FormHelper.builder = CustomBuilder

# You can opt-in to Formtastic's use of the HTML5 `required` attribute on `<input>`, `<select>`
# and `<textarea>` tags by setting this to false (defaults to true).
# Formtastic::FormBuilder.use_required_attribute = true

# You can opt-in to new HTML5 browser validations (for things like email and url inputs) by setting
# this to false. Doing so will add a `novalidate` attribute to the `<form>` tag.
# See http://diveintohtml5.org/forms.html#validation for more info.
# Formtastic::FormBuilder.perform_browser_validations = true
