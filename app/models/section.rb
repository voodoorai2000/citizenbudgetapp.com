class Section
  include Mongoid::Document

  embedded_in :questionnaire
  embeds_many :questions

  field :title, type: String

  validates_presence_of :title

  accepts_nested_attributes_for :questions, allow_destroy: true

  # @todo BreadcrumbHelper should respect :display_name_methods
  def display_name
    title
  end
end
