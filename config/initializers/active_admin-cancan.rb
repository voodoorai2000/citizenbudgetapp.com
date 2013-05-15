module ActiveAdmin
  module ViewHelpers
    # lib/active_admin/view_helpers/auto_link_helper.rb

    def auto_link(resource, link_content = nil)
      content = link_content || display_name(resource)
      if authorized?(:read, resource) && (registration = active_admin_resource_for(resource.class))
        begin
          content = link_to(content, send(registration.route_instance_path, resource))
        rescue
          # ignored
        end
      end
      content
    end
  end
end
