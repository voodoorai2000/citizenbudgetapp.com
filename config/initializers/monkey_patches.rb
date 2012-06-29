class String
  def titleize
    if I18n.locale == 'fr-CA'.to_sym
      underscore.humanize.gsub(/\A('?[a-z])/) { $1.capitalize }
    else
      ActiveSupport::Inflector.titleize(self)
    end
  end
end

# @see https://gist.github.com/2903748
module Mongoid::Document
  # Targets:
  # :date (:date_select)
  # :datetime (:datetime_select)
  # :file
  # :number
  # :select
  # :string
  # :time (:time_select)

  # Targets not used in +default_input_type+:
  # :boolean
  # :check_boxes
  # :hidden
  # :radio
  # :range
  # :text

  # Targets based on attribute name:
  # :country
  # :email
  # :password
  # :phone
  # :search
  # :time_zone
  # :url

  COLUMN_TYPE_MAP = {
    BSON::ObjectId => :string,
    BigDecimal     => :number,
    Float          => :number,
    Integer        => :number,
    Range          => :range,
    Regexp         => :string,
    Symbol         => :string,
    Time           => :datetime,

    # These don't map well (or even transform well):
    Array  => :string,
    Hash   => :string,
    Object => :string,

    # These transform to ActiveRecord types:
    # Boolean
    # Date
    # DateTime
    # String
    # Time

    # In Formtastic 2.2, uncomment:
    # Date     => :date_select,
    # DateTime => :datetime_select,
    # Time     => :datetime_select,

    # Rails defines TimeWithZone:
    # TimeWithZone => :time,
  }

  Column = Struct.new :name, :type
  def column_for_attribute(attribute)
    name = attribute.to_s
    field = self.class.fields[name]
    if field
      if Mongoid::Fields::Internal::ForeignKeys::Object === field
        type = 'select'
      else
        type = field.type
      end
      Column.new(name, COLUMN_TYPE_MAP[type] || type.to_s.downcase.to_sym)
    end
  end
end

module ActiveAdmin
  module Views
    module Pages
      class Base
        # @note Hide "Powered by".
        def build_footer
        end
      end
    end
  end

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
