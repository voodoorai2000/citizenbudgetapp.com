module ActiveAdmin
  module ViewHelpers
    module BreadcrumbHelper

      def breadcrumb_links(path = nil)
        path ||= request.fullpath
        parts = path.gsub(/^\//, '').split('/')
        # The last part of the path is usually rendered as the page title.
        parts.pop unless %w{ create update }.include?(params[:action])
        crumbs = []

        parts.each_with_index do |part, index|
          model = nil
          object = nil
          name = nil
          options = []

          # @todo How to determine whether something is a page?
          if params[:controller] == 'admin/dashboard'
            case index
            when 0
              options = [:admin_root]
              # @todo https://github.com/gregbell/active_admin/pull/1470
              #name = I18n.t part.titlecase, scope: :breadcrumb
              name = part.titlecase
            when 1
              options = [:admin, part]
              # @todo https://github.com/gregbell/active_admin/pull/1470
              #name = I18n.t part.titlecase, scope: :breadcrumb
              name = part.titlecase
            end
          else
            # The zero index is the "admin" part of the path. The next two parts
            # of the path are the resource class and ID, or the parent class and
            # parent ID if this is a nested resource. The rest are for the current
            # resource.
            case index
            when 0
              options = [:admin_root]
              # @todo https://github.com/gregbell/active_admin/pull/1470
              #name = I18n.t part.titlecase, scope: :breadcrumb
              name = part.titlecase
            when 1
              model = respond_to?(:parent?) && parent? && parent.class || resource.class
              options = [:admin, model]
              name = model.model_name.human(:count => 1.1, :default => part.titlecase)
            when 2
              object = respond_to?(:parent?) && parent? && parent || resource
              options = [:admin, object]
              name = display_name(object)
            when 3
              model = resource.class
              options = [:admin, parent, model]
              name = model.model_name.human(:count => 1.1, :default => part.titlecase)
            when 4
              object = resource
              options = [:admin, parent, object]
              name = display_name(object)
            else
              raise NotImplementedError
            end
          end

          no_route = false
          begin
            url = url_for(options)
          rescue NoMethodError
            no_route = true
          end

          crumbs << if (object && cannot?(:read, object)) || (model && cannot?(:read, model)) || no_route
            name
          else
            link_to(name, url)
          end
        end
        crumbs
      end
    end
  end
end
