class Section
  include Mongoid::Document

  embedded_in :questionnaire
  embeds_many :questions

  field :title, type: String
end
