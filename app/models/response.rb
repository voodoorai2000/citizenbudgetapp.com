class Response
  include Mongoid::Document
  include Mongoid::Timestamps

  GENDERS = %w(male female)

  # Don't embed, as a popular questionnaire may be over 16MB in size.
  belongs_to :questionnaire

  field :ip, type: String
  field :initialized_at, type: Time
  field :answers, type: Hash

  # @todo Make fields and validations customizable and configurable.
  field :email, type: String
  field :postal_code, type: String
  field :name, type: String
  field :gender, type: String
  field :age, type: Integer
  field :comments, type: String
  field :newsletter, type: Boolean
  field :subscribe, type: Boolean

  # @todo Rely on JavaScript validation for now, to avoid losing responses, as
  # currently the questionnaire is not properly populated if re-drawn.
=begin
  before_save :sanitize_postal_code

  validates_presence_of :questionnaire_id, :ip, :initialized_at, :email, :postal_code
  validates :email, email: true, allow_blank: true
  validates_format_of :postal_code, with: /\A[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ][0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]\z/, allow_blank: true
  validates_inclusion_of :gender, in: GENDERS, allow_blank: true
  validates_numericality_of :age, only_integer: true, greater_than: 0, allow_blank: true
=end

  def time_to_complete
    persisted? && created_at - initialized_at
  end

  def answer(question)
    answers[question.id.to_s] || question.default_value
  end

private

  # @todo Make this localizable. See also validation engine rule.
  def sanitize_postal_code
    if postal_code?
      self.postal_code = postal_code.upcase.gsub(/[^A-Z0-9]/, '')
    end
  end
end
