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
