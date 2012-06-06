class Questionnaire
  include Mongoid::Document
  include Mongoid::Paranoia

  belongs_to :organization, index: true
  embeds_many :sections
  embeds_many :responses

  field :starts_at, type: Time
  field :ends_at, type: Time

  def scheduled?
    starts_at? && ends_at?
  end

  def active?
    scheduled? && starts_at < Time.now && Time.now < ends_at
  end

  def future?
    scheduled? && Time.now < starts_at
  end

  def past?
    scheduled? && ends_at < Time.now
  end
end
