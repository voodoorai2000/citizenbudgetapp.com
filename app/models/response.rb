# coding: utf-8

class Response
  include Mongoid::Document
  include Mongoid::Timestamps

  # Don't embed, as a popular questionnaire may be over 16MB in size.
  belongs_to :questionnaire

  field :initialized_at, type: Time
  field :answers, type: Hash
  field :ip, type: String
  # The social sharing feature requires email and name.
  field :email, type: String
  field :name, type: String

  validates_presence_of :questionnaire_id, :initialized_at, :answers, :ip

  # Backwards-compatibility
  GENDERS = %w(male female)
  field :postal_code, type: String
  field :gender, type: String
  field :age, type: Integer
  field :comments, type: String
  field :newsletter, type: Boolean, default: true
  field :subscribe, type: Boolean, default: true

  # @return [Float] the time to submit the response in seconds
  def time_to_complete
    persisted? && created_at - initialized_at
  end

  # @param [Question] question a question
  # @return the answer to the question
  def answer(question)
    answers[question.id.to_s] || question.default_value
  end

  # @returns [String] the full first name and last name initial
  def display_name
    if name?
      parts = name.strip.split(' ', 2)
      parts[0] = UnicodeUtils.titlecase(parts[0]) if parts[0][/\A\p{Ll}/]
      parts[1] = "#{UnicodeUtils.upcase(parts[1][0])}." if parts[1]
      parts.join ' '
    end
  end

  # @see http://broadcastingadam.com/2012/07/advanced_caching_part_1-caching_strategies/
  # @see lib/active_record/integration.rb
  # @see lib/active_support/cache.rb
  def cache_key
    # Scope "responses/new" by questionnaire, and expire the cache when the
    # questionnaire changes.
    parts = [super]
    parts << questionnaire.updated_at.utc.to_s(:number) if questionnaire?
    # We can expire the cache when assets change by uncommenting the following
    # line, but we already expire it on each commit by setting RAILS_APP_VERSION
    # to the current Git revision in a pre-commit hook.
    #
    # parts << CitizenBudget::Application.config.assets.version
    parts.join '-'
  end
end
