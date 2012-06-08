module ActiveAdmin
  module Views
    module Pages
      class Base
        # @note Hide "Powered by".
        def build_footer
        end
      end

      class Show
        # @ note From HEAD.
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

  module ViewHelpers
    module BreadcrumbHelper
      # @note Fixes for Mongoid.
      def breadcrumb_links(path = nil)
        path ||= request.fullpath
        parts = path.gsub(/^\//, '').split('/')
        parts.pop unless %w{ create update }.include?(params[:action])
        crumbs = []
        parts.each_with_index do |part, index|
          name = ""
          if part =~ /^(\d+|[a-f0-9]{24})$/ && parent = parts[index - 1]
            begin
              parent_class = parent.singularize.camelcase.constantize
              obj = parent_class.find(part)
              name = obj.display_name if obj.respond_to?(:display_name)
            rescue
            end
          end
          name = part.titlecase if name == ""
          begin
            crumbs << link_to( I18n.translate!("activerecord.models.#{part.singularize}", :count => 2), "/" + parts[0..index].join('/'))
          rescue I18n::MissingTranslationData
            crumbs << link_to( name, "/" + parts[0..index].join('/'))
          end
        end
        crumbs
      end
    end
  end

  class FormBuilder
    # @note From HEAD.
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

    # @note Added +has_many_form.object && +
    def has_many(association, options = {}, &block)
      options = { :for => association }.merge(options)
      options[:class] ||= ""
      options[:class] << "inputs has_many_fields"

      # Add Delete Links
      form_block = proc do |has_many_form|
        block.call(has_many_form) + if has_many_form.object && has_many_form.object.new_record?
                                      template.content_tag :li do
                                        template.link_to I18n.t('active_admin.has_many_delete'), "#", :onclick => "$(this).closest('.has_many_fields').remove(); return false;", :class => "button"
                                      end
                                    else
                                    end
      end

      content = with_new_form_buffer do
        template.content_tag :div, :class => "has_many #{association}" do
          form_buffers.last << template.content_tag(:h3, association.to_s.titlecase)
          inputs options, &form_block

          # Capture the ADD JS
          js = with_new_form_buffer do
            inputs_for_nested_attributes  :for => [association, object.class.reflect_on_association(association).klass.new],
                                          :class => "inputs has_many_fields",
                                          :for_options => {
                                            :child_index => "NEW_RECORD"
                                          }, &form_block
          end

          js = template.escape_javascript(js)
          js = template.link_to I18n.t('active_admin.has_many_new', :model => association.to_s.singularize.titlecase), "#", :onclick => "$(this).before('#{js}'.replace(/NEW_RECORD/g, new Date().getTime())); return false;", :class => "button"

          form_buffers.last << js.html_safe
        end
      end
      form_buffers.last << content.html_safe
    end
  end
end
