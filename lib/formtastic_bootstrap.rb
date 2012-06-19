module FormtasticBootstrap
  class FormBuilder < Formtastic::FormBuilder
    use_required_attribute = true
    perform_browser_validations = true
    default_hint_class = 'help-inline'
    default_inline_error_class = 'help-inline'

    def action_class(as)
      @input_classes_cache ||= {}
      @input_classes_cache[as] ||= begin
        begin
          begin
            custom_action_class_name(as).constantize
          rescue NameError
            begin
              bootstrap_action_class_name(as).constantize
            rescue NameError
              standard_action_class_name(as).constantize
            end
          end
        rescue NameError
          raise Formtastic::UnknownActionError
        end
      end
    end

    # Add bootstrap_input_class_name.
    def input_class_with_const_defined(as)
      input_class_name = custom_input_class_name(as)

      if ::Object.const_defined?(input_class_name)
        input_class_name.constantize
      elsif FormtasticBootstrap::Inputs.const_defined?(input_class_name)
        bootstrap_input_class_name(as).constantize
      elsif Formtastic::Inputs.const_defined?(input_class_name)
        standard_input_class_name(as).constantize
      else
        raise Formtastic::UnknownInputError
      end
    end

    # Add bootstrap_input_class_name.
    def input_class_by_trying(as)
      begin
        custom_input_class_name(as).constantize
      rescue NameError
        begin
          bootstrap_input_class_name(as).constantize
        rescue NameError
          standard_input_class_name(as).constantize
        end
      end
    rescue NameError
      raise Formtastic::UnknownInputError
    end

    # New method.
    def bootstrap_action_class_name(as)
      "FormtasticBootstrap::Actions::#{as.to_s.camelize}Action"
    end

    # New method.
    def bootstrap_input_class_name(as)
      "FormtasticBootstrap::Inputs::#{as.to_s.camelize}Input"
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

  # Not implemented:
  # * LinkAction
  module Actions
    module Base
      # Add class.
      def extra_button_html_options
        {:type => method, :class => 'btn btn-primary'}
      end

      # Remove template.content_tag(:li, ...)
      def wrapper(&block)
        template.capture(&block)
      end
    end

    class ButtonAction < Formtastic::Actions::ButtonAction
      include Base
    end

    class InputAction < Formtastic::Actions::InputAction
      include Base
    end
  end

  # Not implemented:
  # * CheckboxesInput
  # * CountryInput
  # * DateInput
  # * DateTimeInput
  # * SelectInput
  # * TimeInput
  # * TimeZoneInput
  module Inputs
    module Base
      # Change class.
      def wrapper_html_options
        classes = ['control-group']
        classes << 'error' if errors?
        {:class => classes.join(' ')}
      end

      # Change class.
      def label_html_options
        {:for => input_html_options[:id], :class => ['control-label']}
      end

      # Add controls div.
      def to_html
        form_helper = case options[:as]
        when :string
          :text_field
        when :text
          :text_area
        else
          "#{options[:as]}_field"
        end

        template.content_tag(:div,
          label_html << template.content_tag(:div,
            [builder.send(form_helper, method, input_html_options), error_html, hint_html].join("\n").html_safe,
            :class => 'controls'
          ),
          wrapper_html_options
        )
      end
    end

    class HiddenInput < Formtastic::Inputs::HiddenInput
      # Remove input_wrapping.
      def to_html
        builder.hidden_field(method, input_html_options)
      end
    end

    class BooleanInput < Formtastic::Inputs::BooleanInput
      include Base

      # Add class.
      def label_html_options
        {:for => input_html_options[:id], :class => ['checkbox']}
      end

      # Add controls div.
      def to_html
        template.content_tag(:div,
          hidden_field_html << template.content_tag(:div,
            [label_with_nested_checkbox, error_html, hint_html].join("\n").html_safe,
            :class => 'controls'
          ),
          wrapper_html_options
        )
      end
    end

    class RadioInput < Formtastic::Inputs::RadioInput
      include Base

      # Remove wrappers.
      def to_html
        template.content_tag(:div,
          label_html << template.content_tag(:div,
            collection.map { |choice|
              choice_html(choice)
            }.join("\n").html_safe,
            :class => 'controls'
          ),
          wrapper_html_options
        )
      end

      # Change :class from nil to 'radio inline'.
      def choice_html(choice)
        template.content_tag(:label,
          builder.radio_button(input_name, choice_value(choice), input_html_options.merge(choice_html_options(choice)).merge(:required => false)) <<
          choice_label(choice),
          label_html_options.merge(:for => choice_input_dom_id(choice), :class => 'radio inline')
        )
      end
    end

    class FileInput < Formtastic::Inputs::FileInput
      include Base
    end
    class TextInput < Formtastic::Inputs::TextInput
      include Base
    end

    # Numeric inputs.
    class NumberInput < Formtastic::Inputs::NumberInput
      include Base
    end
    class RangeInput < Formtastic::Inputs::RangeInput
      include Base
    end

    # Stringish inputs.
    class EmailInput < Formtastic::Inputs::EmailInput
      include Base
    end
    class PasswordInput < Formtastic::Inputs::PasswordInput
      include Base
    end
    class PhoneInput < Formtastic::Inputs::PhoneInput
      include Base
    end
    class SearchInput < Formtastic::Inputs::SearchInput
      include Base
    end
    class StringInput < Formtastic::Inputs::StringInput
      include Base
    end
    class UrlInput < Formtastic::Inputs::UrlInput
      include Base
    end
  end
end
