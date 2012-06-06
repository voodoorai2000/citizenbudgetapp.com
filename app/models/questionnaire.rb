class Questionnaire
  include Mongoid::Document

  belongs_to :organization
  embeds_many :sections
  embeds_many :responses

  field :starts_at, type: Time
  field :ends_at, type: Time

  def active?
    starts_at < Time.now && Time.now < ends_at
  end

  def future?
    Time.now < starts_at
  end

  def past?
    ends_at < Time.now
  end
end
