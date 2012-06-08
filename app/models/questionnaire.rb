class Questionnaire
  include Mongoid::Document
  include Mongoid::Paranoia

  belongs_to :organization, index: true
  embeds_many :sections
  embeds_many :responses

  field :starts_at, type: Time
  field :ends_at, type: Time

  validates_presence_of :organization_id

  scope :active, where(:starts_at.ne => nil, :ends_at.ne => nil, :starts_at.lte => Time.now, :ends_at.gte => Time.now)

  def title
    if scheduled?
      "#{organization.name}: #{starts_at.to_s(:short)} to #{ends_at.to_s(:short)}"
    else
      organization.name
    end
  end

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
