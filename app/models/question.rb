# Keys are based on the Drupal Form API, one of the best thought-out methods
# of describing arbitrary forms.
#
# @see http://api.drupal.org/api/drupal/developer!topics!forms_api_reference.html/7
class Question
  include Mongoid::Document

  WIDGETS = %w(checkbox onoff radio select slider text textarea)

  embedded_in :section

  # Drupal Form API keys
  field :title, type: String
  field :description, type: String
  field :options, type: Array
  field :default_value
  field :required, type: Boolean

  field :widget, type: String
  field :unit_amount, type: Float
  field :unit_name, type: String

  attr_accessor :minimum_units, :maximum_units, :step

  validates_presence_of :title, :widget
  validates_inclusion_of :widget, in: WIDGETS, allow_blank: true
  validates_numericality_of :unit_amount, allow_blank: true

  validates_presence_of :unit_amount, :default_value, if: ->(q){%w(checkbox onoff radio select slider).include? q.widget}
  validates_presence_of :options, if: ->(q){%w(radio select slider).include? q.widget}

  # Slider validations.
  validates_presence_of :maximum_units, :minimum_units, :step, if: ->(q){q.widget == 'slider'}
  validates_numericality_of :maximum_units, :minimum_units, if: ->(q){q.widget == 'slider'}
  validates_numericality_of :step, greater_than: 0, if: ->(q){q.widget == 'slider'}
  validate :maximum_units_must_be_greater_than_minimum_units, if: ->(q){q.widget == 'slider'}

  before_save :set_options

private
  def maximum_units_must_be_greater_than_minimum_units
    if widget == 'slider' && minimum_units.present? && maximum_units.present? && minimum_units >= maximum_units
      errors.add :maximum_units, I18n.t('errors.messages.maximum_units_must_be_greater_than_minimum_units')
    end
  end

  def set_options
    if widget == 'slider' && minimum_units.present? && maximum_units.present?
      self.options = (minimum_units..maximum_units).step(step || 1).to_a
      self.options << maximum_units unless options.last == maximum_units
    elsif String === options
      self.options = options.split(',').map(&:strip)
    end
  end
end
