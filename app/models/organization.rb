class Organization
  include Mongoid::Document

  has_many :questionnaires

  field :name, type: String
end
