module ActiveAdmin
  class Resource
    # lib/active_admin/resource/naming.rb

    # Returns the name to call this resource such as "Bank Account"
    def resource_label
      if @options[:as]
        @options[:as]
      else
         resource_name.human #resource_name.human(:default => resource_name.gsub('::', ' ')).titleize
       end
    end

    # Returns the plural version of this resource such as "Bank Accounts"
    def plural_resource_label
      if @options[:as]
        @options[:as].pluralize
      else
        resource_name.human :count => 1.1 #resource_name.human(:count => 1.1, :default => resource_label.pluralize).titleize
      end
    end
  end
end
