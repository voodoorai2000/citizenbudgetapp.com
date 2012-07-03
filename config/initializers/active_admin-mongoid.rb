module ActiveAdmin
  module ViewHelpers
    module BreadcrumbHelper
      # @note Fixes for Mongoid. Use display_name method.
      def breadcrumb_links(path = nil)
        path ||= request.fullpath
        parts = path.gsub(/^\//, '').split('/')
        parts.pop unless %w{ create update }.include?(params[:action])
        crumbs = []
        obj = nil
        parts.each_with_index do |part, index|
          name = ""
          if part =~ /^\d|^[a-f0-9]{24}$/ && parent = parts[index - 1]
            begin
              if obj && obj.respond_to?(parent)
                parent_class = obj.send(parent)
              else
                parent_class = parent.singularize.camelcase.constantize
              end
              obj = parent_class.find(part[/^[a-f0-9]{24}$/] ? part : part.to_i)
              name = display_name(obj)
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
end
