module ActiveAdmin
  module Views
    module Pages
      class Base
        def build_footer
          # Hide "Powered by"
        end
      end

      class Show
        def default_title
          title = display_name(resource)

          if title.nil? || title.empty? || title == resource.to_s
            title = "#{active_admin_config.resource_label} ##{resource.id}"
          end

          title
        end
      end
    end
  end

  class FormBuilder < ::Formtastic::FormBuilder
    def actions(*args, &block)
      content = with_new_form_buffer do
        block_given? ? super : super { commit_action_with_cancel_link }
      end
      form_buffers.last << content.html_safe
    end

    def action(*args)
      content = with_new_form_buffer { super }
      form_buffers.last << content.html_safe
    end

    def commit_action_with_cancel_link
      content = action(:submit)
      content << cancel_link
    end
  end
end
