require 'mail'

class Questionnaire
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Mongoid::MultiParameterAttributes

  belongs_to :organization, index: true
  embeds_many :sections
  has_many :responses
  mount_uploader :logo, LogoUploader

  field :title, type: String
  field :locale, type: String
  field :logo, type: String
  field :description, type: String
  field :starts_at, type: Time
  field :ends_at, type: Time
  field :introduction, type: String
  field :domain, type: String
  field :reply_to, type: String
  field :thank_you_template, type: String

  # Third-party integration.
  field :google_analytics, type: String
  field :twitter_screen_name, type: String
  field :twitter_text, type: String
  field :twitter_share_text, type: String
  field :facebook_app_id, type: String

  validates_presence_of :title, :organization_id
  validates_inclusion_of :locale, in: Locale.available_locales, allow_blank: true
  validates_length_of :twitter_text, maximum: 140, allow_blank: true
  validates_length_of :twitter_share_text, maximum: 140, allow_blank: true
  validate :ends_at_must_be_greater_than_starts_at
  validate :domain_must_be_active
  validate :reply_to_must_be_valid

  before_validation :sanitize_domain
  before_save :add_domain

  scope :active, where(:starts_at.ne => nil, :ends_at.ne => nil, :starts_at.lte => Time.now, :ends_at.gte => Time.now)
  scope :future, where(:starts_at.ne => nil, :starts_at.gt => Time.now)
  scope :past, where(:ends_at.ne => nil, :ends_at.lt => Time.now)

  def self.find_by_domain(domain)
    domain && any_in(domain: [domain, sanitize_domain(domain)]).first
  end

  def find_question(question)
    questions.find do |q|
      q.id.to_s == question.id.to_s
    end
  end

  def find_question_by_id(id)
    questions.find do |q|
      q.id.to_s == id
    end
  end

  def questions
    sections.reduce([]) do |memo,section|
      memo + section.questions
    end
  end

  def domain_url
    domain? && "http://#{domain}"
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

  def maximum_amount
    sections.reduce(0) do |sum,section|
      sum + section.questions.reduce(0) do |sum,q|
        if section.group == 'revenue'
          sum + (q.maximum_amount || 0)
        else
          sum - (q.minimum_amount || 0)
        end
      end
    end
  end

  def minimum_amount
    sections.reduce(0) do |sum,section|
      sum + section.questions.reduce(0) do |sum,q|
        if section.group == 'revenue'
          sum + (q.minimum_amount || 0)
        else
          sum - (q.maximum_amount || 0)
        end
      end
    end
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

  def reply_to_must_be_valid
    if reply_to?
      begin
        address = Mail::Address.new Mail::Address.new(reply_to).address
        unless (address.domain && address.__send__(:tree).domain.dot_atom_text.elements.size > 1 rescue false)
          errors.add :reply_to, I18n.t('errors.messages.reply_to_must_be_valid')
        end
      rescue Mail::Field::ParseError
        errors.add :reply_to, I18n.t('errors.messages.reply_to_must_be_valid')
      end
    end
  end

  def add_domain
    if domain_changed?
      domains = HerokuClient.list_domains

      if domain_was.present?
        queue = [domain_was]
        if domain_was.split('.').size == 2
          queue << "www.#{domain_was}"
        end
        queue.each do |d|
          if domains.include? d
            HerokuClient.remove_domain d
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
            HerokuClient.add_domain d
          end
        end
      end
    end
  end
end
