class Questionnaire
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::MultiParameterAttributes

  belongs_to :organization, index: true
  embeds_many :sections
  embeds_many :responses

  field :starts_at, type: Time
  field :ends_at, type: Time

  validates_presence_of :organization_id
  validate :ends_at_must_be_greater_than_starts_at

  scope :active, where(:starts_at.ne => nil, :ends_at.ne => nil, :starts_at.lte => Time.now, :ends_at.gte => Time.now)
  scope :future, where(:starts_at.ne => nil, :starts_at.gt => Time.now)
  scope :past, where(:ends_at.ne => nil, :ends_at.lt => Time.now)

  def display_name
    if starts_at? && ends_at?
      I18n.t(:period, starts_at: I18n.l(starts_at, format: :short), ends_at: I18n.l(ends_at, format: :short))
    elsif starts_at?
      I18n.t(:starting, date: I18n.l(starts_at, format: :short))
    elsif ends_at?
      I18n.t(:ending, date: I18n.l(ends_at, format: :short))
    else
      I18n.t(:untitled)
    end
  end

  def active?
    starts_at? && ends_at? && starts_at < Time.now && Time.now < ends_at
  end

  def future?
    starts_at? && Time.now < starts_at
  end

  def past?
    ends_at? && ends_at < Time.now
  end

private

  def ends_at_must_be_greater_than_starts_at
    if starts_at? && ends_at? && starts_at > ends_at
      errors.add :ends_at, I18n.t('errors.messages.ends_at_must_be_greater_than_starts_at')
    end
  end
end
