module ActiveAdmin
  module Views
    module Pages
      class Base
        # Hide "Powered by".
        def build_footer
        end
      end
    end
  end
end

module ActiveAdmin
  class MenuBuilder
  private
    def build_menu
      menu = Menu.new

      Dashboards.add_to_menu(namespace, menu)

      namespace.resources.each do |resource|
        register_with_menu(menu, resource) if resource.include_in_menu?
      end

      # Add language switcher.
      item = MenuItem.new label: I18n.t(:language), url: '#', priority: 100
      Locale::LOCALES.each do |k,v|
        item.add MenuItem.new(label: v, url: "?locale=#{k}")
      end
      menu.add item

      menu
    end
  end
end
