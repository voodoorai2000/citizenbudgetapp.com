# Keys are based on the Drupal Form API, one of the best thought-out methods
# of describing arbitrary forms.
#
# @see http://api.drupal.org/api/drupal/developer!topics!forms_api_reference.html/7
class Question
  include Mongoid::Document

  TYPES = %w(checkbox radio text select)
  WIDGET = %w(default onoff slider textarea)

  embedded_in :section

  # Drupal Form API keys
  field :title, type: String
  field :description, type: String
  field :type, type: String
  field :widget, type: String
  field :options, type: String # @todo set min, max, step
  field :default_value
  field :required, type: Boolean

  field :unit_amount, type: Float
  field :unit_name, type: String

  validates_presence_of :title, :type, :unit_amount
  validates_inclusion_of :type, in: TYPES
  validates_inclusion_of :widget, in: WIDGET, allow_blank: true
  validates_presence_of :options, if: ->(q){q.type == 'select'}
  validates_numericality_of :unit_amount
end
