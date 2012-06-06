class Organization
  include Mongoid::Document
  include Mongoid::Paranoia

  has_many :questionnaires

  field :name, type: String

  validates_presence_of :name
end
