class Questionnaire
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::MultiParameterAttributes

  belongs_to :organization, index: true
  embeds_many :sections
  embeds_many :responses

  field :title, type: String
  field :starts_at, type: Time
  field :ends_at, type: Time
  field :domain, type: String
  field :facebook_app_id, type: String
  field :google_analytics, type: String

  validates_presence_of :title, :organization_id
  validate :ends_at_must_be_greater_than_starts_at
  validate :domain_must_be_active

  before_validation :sanitize_domain
  before_save :add_domain

  scope :active, where(:starts_at.ne => nil, :ends_at.ne => nil, :starts_at.lte => Time.now, :ends_at.gte => Time.now)
  scope :future, where(:starts_at.ne => nil, :starts_at.gt => Time.now)
  scope :past, where(:ends_at.ne => nil, :ends_at.lt => Time.now)

  def self.find_by_domain(domain)
    any_in(domain: [domain, sanitize_domain(domain)]).first
  end

  #def display_name
  #  if starts_at? && ends_at?
  #    I18n.t('questionnaire.period', starts_at: I18n.l(starts_at, format: :short), ends_at: I18n.l(ends_at, format: :short))
  #  elsif starts_at?
  #    I18n.t('questionnaire.starting', date: I18n.l(starts_at, format: :short))
  #  elsif ends_at?
  #    I18n.t('questionnaire.ending', date: I18n.l(ends_at, format: :short))
  #  else
  #    I18n.t('questionnaire.untitled')
  #  end
  #end

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

  # Removes the protocol and trailing slash, if present.
  # @param [String] domain a domain name
  # @return [String] the domain without the protocol or trailing slash
  def self.sanitize_domain(domain)
    domain.sub(%r{\A(https?://)?(www\.)?}, '').sub(%r{/\z}, '')
  end

  def sanitize_domain
    if domain?
      self.domain = self.class.sanitize_domain domain
    end
  end

  def ends_at_must_be_greater_than_starts_at
    if starts_at? && ends_at? && starts_at > ends_at
      errors.add :ends_at, I18n.t('errors.messages.ends_at_must_be_greater_than_starts_at')
    end
  end

  def domain_must_be_active
    if domain?
      begin
        Socket.gethostbyname domain
      rescue SocketError
        errors.add :domain, I18n.t('errors.messages.domain_must_be_active')
      end
    end
  end

  def add_domain
    if domain_changed?
      domains = Heroku.list_domains

      if domain_was.present?
        queue = [domain_was]
        if domain_was.split('.').size == 2
          queue << "www.#{domain_was}"
        end
        queue.each do |d|
          if domains.include? d
            Heroku.remove_domain d
          end
        end
      end

      if domain.present?
        queue = [domain]
        if domain.split('.').size == 2
          queue << "www.#{domain}"
        end
        queue.each do |d|
          unless domains.include? d
            Heroku.add_domain d
          end
        end
      end
    end
  end
end
