class Section
  include Mongoid::Document

  GROUPS = %w(revenue expense)

  embedded_in :questionnaire
  embeds_many :questions

  field :title, type: String
  field :description, type: String
  field :extra, type: String
  field :embed, type: String
  field :group, type: String
  field :position, type: Integer
  index position: 1

  validates_presence_of :title, :group
  validates_inclusion_of :group, in: GROUPS, allow_blank: true

  accepts_nested_attributes_for :questions, reject_if: :all_blank, allow_destroy: true

  after_save :touch_questionnaire # @see https://github.com/mongoid/mongoid/pull/2195

  default_scope asc(:position)

  def position
    read_attribute(:position) || _index
  end

  # @return [Boolean] whether all questions are survey questions
  def survey?
    questions.all? do |question|
      question.survey?
    end
  end

private

  def touch_questionnaire
    questionnaire.touch
  end
end
