class Section
  include Mongoid::Document

  GROUPS = %w(simulator custom other)

  embedded_in :questionnaire
  embeds_many :questions

  field :title, type: String
  field :description, type: String
  field :extra, type: String
  field :embed, type: String
  field :group, type: String
  field :position, type: Integer
  index position: 1

  validates_presence_of :group
  validates_inclusion_of :group, in: GROUPS, allow_blank: true

  accepts_nested_attributes_for :questions, reject_if: :all_blank, allow_destroy: true

  after_initialize :set_default_group
  after_save :touch_questionnaire # @see https://github.com/mongoid/mongoid/pull/2195

  scope :simulator, where(:group.in => %w(simulator custom))
  scope :budgetary, where(group: 'simulator')
  scope :nonbudgetary, where(group: 'other')
  default_scope asc(:position)

  # @return [String] the name to display in the administrative interface
  def name
    title? && title || I18n.t(:untitled)
  end

  # @return [Boolean] whether the "Read more" content is a URL
  def extra_url?
    extra? && extra[%r{\Ahttps?://\S+\z}]
  end

  # @return [Boolean] whether all questions are nonbudgetary questions
  def nonbudgetary?
    questions.all?(&:nonbudgetary?)
  end

  def position
    read_attribute(:position) || _index
  end

private

  def set_default_group
    self.group ||= 'simulator'
  end

  def touch_questionnaire
    questionnaire.touch
  end
end
