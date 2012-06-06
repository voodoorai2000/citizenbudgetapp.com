class Response
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :questionnaire

  field :ip, type: String
  field :answers, type: Hash

  attr_accessible :answers

  validates_presence_of :ip
end
