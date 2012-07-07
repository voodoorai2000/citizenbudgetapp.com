module ActiveAdmin
  class Resource
    # lib/active_admin/resource/naming.rb

    # Returns the name to call this resource such as "Bank Account"
    def resource_label
      if @options[:as]
        @options[:as]
      else
         resource_name.human(:default => resource_name.gsub('::', ' ')) #resource_name.human(:default => resource_name.gsub('::', ' ')).titleize
       end
    end

    # Returns the plural version of this resource such as "Bank Accounts"
    def plural_resource_label
      if @options[:as]
        @options[:as].pluralize
      else
        resource_name.human(:count => 1.1, :default => resource_label.pluralize) #resource_name.human(:count => 1.1, :default => resource_label.pluralize).titleize
      end
    end
  end

  module Views
    class AttributesTable
      def header_content_for(attr)
        @record.class.respond_to?(:human_attribute_name) ? @record.class.human_attribute_name(attr) : attr.to_s.titleize # @record.class.respond_to?(:human_attribute_name) ? @record.class.human_attribute_name(attr).titleize : attr.to_s.titleize
      end
    end

    class TableFor
      class Column
        def pretty_title(raw)
          if raw.is_a?(Symbol)
            if @options[:i18n] && @options[:i18n].respond_to?(:human_attribute_name) && human_name = @options[:i18n].human_attribute_name(raw)
              raw = human_name
            end

            raw.to_s # raw.to_s.titleize
          else
            raw
          end
        end
      end
    end
  end
end
