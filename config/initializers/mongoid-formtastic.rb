# @see https://gist.github.com/2903748
require 'formtastic/version'

# Formtastic sets default input types for ActiveRecord column types. This does
# the same for Mongoid field types.
module Mongoid::Document
  FORMTASTIC_2_2 = Formtastic::VERSION[/\A2\.2\.\d\z/]

  # Map Mongoid field types to either ActiveRecord column types (which
  # Formtastic understands) or directly to Formtastic input types.
  #
  # ActiveRecord column types:
  # * :binary
  # * :boolean
  # * :date
  # * :datetime
  # * :decimal
  # * :float
  # * :integer
  # * :string
  # * :text
  # * :time
  # * :timestamp

  # Formtastic input types:
  # * :boolean
  # * :check_boxes
  # * :country
  # * :date_select
  # * :datetime_select
  # * :email
  # * :file
  # * :hidden
  # * :number
  # * :password
  # * :phone
  # * :radio
  # * :range
  # * :search
  # * :select
  # * :string
  # * :text
  # * :time_select
  # * :time_zone
  # * :url
  #
  # @see http://mongoid.org/en/mongoid/docs/documents.html#fields
  COLUMN_TYPE_MAP = {
    Array                 => :string,
    BigDecimal            => :decimal,
    Boolean               => :boolean,
    Date                  => FORMTASTIC_2_2 ? :date_select : :date,
    DateTime              => FORMTASTIC_2_2 ? :datetime_select : :datetime,
    Float                 => :float,
    Hash                  => :string,
    Integer               => :integer,
    Moped::BSON::ObjectId => :string,
    Range                 => :range,
    Regexp                => :string,
    String                => :string,
    Symbol                => :string,
    # The Formtastic :time input type displays only hours, minutes and seconds,
    # but a Time object has both date and time parts.
    Time                  => FORMTASTIC_2_2 ? :datetime_select : :datetime,
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
