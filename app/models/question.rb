# Keys are based on the Drupal Form API, one of the best thought-out methods
# of describing arbitrary forms.
#
# @see http://api.drupal.org/api/drupal/developer!topics!forms_api_reference.html/7
class Question
  include Mongoid::Document

  # @todo Need to be able to map an amount to each radio and select option, in
  #   which case we need a new :amounts array field?
  WIDGETS = %w(checkbox onoff radio select slider text textarea)

  embedded_in :section

  # Drupal Form API keys
  field :title, type: String
  field :description, type: String
  field :options, type: Array
  field :default_value
  field :required, type: Boolean

  field :widget, type: String
  field :extra, type: String
  field :unit_amount, type: Float
  field :unit_name, type: String
  field :position, type: Integer
  index position: 1

  attr_accessor :minimum_units, :maximum_units, :step, :options_as_list

  validates_presence_of :title, :widget
  validates_inclusion_of :widget, in: WIDGETS, allow_blank: true
  validates_numericality_of :unit_amount, allow_blank: true

  validates_presence_of :unit_amount, :default_value, if: ->(q){%w(checkbox onoff slider).include? q.widget}
  validates_presence_of :options, if: ->(q){%w(radio select slider).include? q.widget}

  # Slider validations.
  validates_presence_of :minimum_units, :maximum_units, :step, if: ->(q){q.widget == 'slider'}
  validates_numericality_of :minimum_units, :maximum_units, only_integer: true, if: ->(q){q.widget == 'slider'}
  validates_numericality_of :step, greater_than: 0, if: ->(q){q.widget == 'slider'}
  validate :maximum_units_must_be_greater_than_minimum_units, if: ->(q){q.widget == 'slider'}

  after_initialize :get_options
  before_validation :set_options

  default_scope asc(:position)

  def position
    read_attribute(:position) || _index
  end

private
  def get_options
    if widget == 'slider' && options.present?
      @minimum_units = options.first.to_i
      @maximum_units = options.last.to_i
      @step = options[1] - options[0]
    elsif %w(radio select).include?(widget) && options.present?
      @options_as_list = options.join ','
    end
  end

  def set_options
    if widget == 'slider' && minimum_units.present? && maximum_units.present? && step.present?
      self.options = (minimum_units.to_i..maximum_units.to_i).step(step.to_f).to_a
      self.options << maximum_units.to_i unless options.last == maximum_units.to_i
    elsif %w(radio select).include?(widget) && options_as_list.present?
      self.options = options_as_list.split(',').map(&:strip)
    end
  end

  def maximum_units_must_be_greater_than_minimum_units
    if widget == 'slider' && minimum_units.present? && maximum_units.present? && minimum_units.to_i >= maximum_units.to_i
      errors.add :maximum_units, I18n.t('errors.messages.maximum_units_must_be_greater_than_minimum_units')
    end
  end
end
