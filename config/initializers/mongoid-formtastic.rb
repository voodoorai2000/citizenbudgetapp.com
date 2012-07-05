# @see https://gist.github.com/2903748
module Mongoid::Document
  # ActiveRecord column types:
  # :binary
  # :boolean
  # :date
  # :datetime
  # :decimal
  # :float
  # :integer
  # :string
  # :text
  # :time
  # :timestamp

  # Formtastic input types:
  # :boolean
  # :check_boxes
  # :country
  # :date_select
  # :datetime_select
  # :email
  # :file
  # :hidden
  # :number
  # :password
  # :phone
  # :radio
  # :range
  # :search
  # :select
  # :string
  # :text
  # :time_select
  # :time_zone
  # :url

  # @see http://mongoid.org/en/mongoid/docs/documents.html#fields
  COLUMN_TYPE_MAP = {
    Array                 => :string,
    BigDecimal            => :decimal,
    Boolean               => :boolean,
    Date                  => :date, # :date_select Formtastic 2.2
    DateTime              => :datetime, # :datetime_select Formtastic 2.2
    Float                 => :float,
    Hash                  => :string,
    Integer               => :integer,
    Moped::BSON::ObjectId => :string,
    Range                 => :range,
    Regexp                => :string,
    String                => :string,
    Symbol                => :string,
    # The Formtastic :time input type displays only hours, minutes and seconds.
    Time                  => :datetime, # :datetime_select Formtastic 2.2
    # Raises "uninitialized constant Mongoid::Document::TimeWithZone"
    # TimeWithZone          => :datetime,

    # Fields with no type are objects.
    Object => :string,
  }

  Column = Struct.new :name, :type
  def column_for_attribute(attribute)
    name = attribute.to_s
    field = fields[name]
    if field
      type = Mongoid::Fields::ForeignKey === field ? 'select' : field.type
      Column.new(name, COLUMN_TYPE_MAP[type] || type.to_s.downcase.to_sym)
    end
  end
end
