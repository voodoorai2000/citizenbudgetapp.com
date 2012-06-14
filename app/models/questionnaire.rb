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
  field :google_analytics, type: String

  validates_presence_of :title, :organization_id
  validate :ends_at_must_be_greater_than_starts_at
  validate :domain_must_be_active

  before_validation :sanitize_domain
  before_save :add_domain

  scope :active, where(:starts_at.ne => nil, :ends_at.ne => nil, :starts_at.lte => Time.now, :ends_at.gte => Time.now)
  scope :future, where(:starts_at.ne => nil, :starts_at.gt => Time.now)
  scope :past, where(:ends_at.ne => nil, :ends_at.lt => Time.now)

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
  def sanitize_domain
    if domain?
      self.domain = domain.sub(%r{\Ahttps?://(www\.)?}, '').sub(%r{/\z}, '')
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

  # @return [Faraday::Connection] an HTTP client
  def client
    @client ||= Faraday.new 'https://api.heroku.com', headers: {'Accept' => 'application/json'} do |builder|
      builder.request :url_encoded
      builder.request :basic_auth, nil, ENV['HEROKU_API_KEY']
      builder.response :json
      builder.adapter :net_http
    end
  end

  # @return [Array<String>] a list of domain names
  def heroku_list_domains
    client.get("/apps/#{ENV['HEROKU_APP']}/domains").body.map{|domain| domain['domain']}
  end

  # @param [String] domain a domain name
  # @return [Boolean] whether domain was added
  def heroku_add_domain(domain)
    client.post("/apps/#{ENV['HEROKU_APP']}/domains", domain_name: {domain: domain}).body['domain'] == domain
  end

  def add_domain
    if domain_changed?
      # @todo check if domain in list, add domain
      if domain.split('.').size == 2
        # @todo check if domain in list
        client.add_domain app_name, "www.#{domain}"
      end
    end
  end
end
