class Organization
  include Mongoid::Document
  include Mongoid::Paranoia

  LOCALES = %w(en_US fr_CA)

  has_many :questionnaires

  field :name, type: String
  field :locale, type: String

  validates_presence_of :name
  validates_inclusion_of :locale, in: LOCALES, allow_blank: true

  def display_name
    name
  end
end
