# Keys are based on the Drupal Form API, one of the best thought-out methods
# of describing arbitrary forms.
#
# @see http://api.drupal.org/api/drupal/developer!topics!forms_api_reference.html/7
class Question
  include Mongoid::Document

  # @todo Need to be able to map an amount to each option for checkboxes, radio
  # and select widgets, in which case we need a new :amounts array field?
  # @note The check box widget is used uniquely in non-budgetary questions. Use
  # the on/off switch for budgetary questions.
  WIDGETS = %w(checkbox checkboxes onoff radio readonly scaler select slider text textarea)

  # @note Check boxes, radio buttons and select lists are currently used for
  #   non-budgetary questions, but that will not necessarily the case.
  NONBUDGETARY_WIDGETS = %w(checkbox checkboxes radio readonly select text textarea)

  embedded_in :section

  # Drupal Form API keys
  field :title, type: String
  field :description, type: String
  field :options, type: Array
  field :default_value # default_value needs to be cast before use
  field :size, type: Integer
  field :maxlength, type: Integer
  field :placeholder, type: String # no #placeholder in Drupal FAPI: http://drupal.org/project/elements
  field :rows, type: Integer
  field :cols, type: Integer
  field :required, type: Boolean

  field :widget, type: String
  field :extra, type: String
  field :embed, type: String
  field :unit_amount, type: Float
  field :unit_name, type: String
  field :position, type: Integer
  index position: 1

  attr_accessor :minimum_units, :maximum_units, :step, :options_as_list

  validates_presence_of :widget
  validates_presence_of :title, unless: ->(q){q.widget == 'readonly'}
  validates_inclusion_of :widget, in: WIDGETS, allow_blank: true
  validates_numericality_of :unit_amount, allow_blank: true

  # HTML attribute validations.
  validates_numericality_of :size, :maxlength, greater_than: 0, only_integer: true, allow_blank: true, if: ->(q){q.widget == 'text'}
  validates_numericality_of :rows, :cols, greater_than: 0, only_integer: true, allow_blank: true, if: ->(q){q.widget == 'textarea'}

  # Budgetary widget validations.
  validates_presence_of :unit_amount, :default_value, if: ->(q){%w(onoff scaler slider).include? q.widget}
  validates_numericality_of :unit_amount, :default_value, allow_blank: true, if: ->(q){%w(onoff scaler slider).include? q.widget}
  validates_presence_of :options, if: ->(q){%w(checkbox checkboxes onoff radio scaler select slider).include? q.widget}

  # Slider validations.
  validates_presence_of :minimum_units, :maximum_units, :step, if: ->(q){%w(scaler slider).include? q.widget}
  validates_numericality_of :minimum_units, :maximum_units, allow_blank: true, if: ->(q){%w(scaler slider).include? q.widget}
  validates_numericality_of :step, greater_than: 0, allow_blank: true, if: ->(q){%w(scaler slider).include? q.widget}
  validate :maximum_units_must_be_greater_than_minimum_units, if: ->(q){%w(scaler slider).include? q.widget}
  validate :default_value_must_be_between_minimum_and_maximum, if: ->(q){%w(scaler slider).include? q.widget}

  after_initialize :get_options
  before_validation :set_options
  before_save :strip_title

  scope :budgetary, where(:widget.nin => NONBUDGETARY_WIDGETS)
  scope :nonbudgetary, where(:widget.in => NONBUDGETARY_WIDGETS)
  default_scope asc(:position)

  # @return [String] the name to display in the administrative interface
  def name
    title? && title || I18n.t(:untitled)
  end

  # @return [Boolean] whether the "Read more" content is a URL
  def extra_url?
    extra? && extra[%r{\Ahttps?://\S+\z}]
  end

  # @return [Boolean] whether the widget is read-only
  def readonly?
    widget == 'readonly'
  end

  # @return [Boolean] whether it is a nonbudgetary question
  def nonbudgetary?
    NONBUDGETARY_WIDGETS.include? widget
  end

  # @return [Boolean] whether it is a budgetary question
  def budgetary?
    !nonbudgetary?
  end

  # @return [Boolean] whether multiple values can be selected
  def multiple?
    widget == 'checkboxes'
  end

  # @return [Boolean] whether the widget is checked by default
  def checked?
    %w(checkbox onoff).include?(widget) && default_value.to_f == 1
  end

  # @return [Boolean] whether the widget is unchecked by default
  def unchecked?
    %w(checkbox onoff).include?(widget) && default_value.to_f == 0
  end

  # @return [Float] the maximum value of the widget
  def maximum_amount
    if %w(onoff scaler slider).include? widget
      (maximum_units - default_value.to_f) * unit_amount
    end
  end

  # @return [Float] the minimum value of the widget
  def minimum_amount
    if %w(onoff scaler slider).include? widget
      (minimum_units - default_value.to_f) * unit_amount
    end
  end

  # Casts a value according to the question's widget.
  #
  # @param value a value
  # @return the cast value
  def cast_value(value)
    if %w(checkbox onoff).include? widget
      Integer value.to_s rescue value
    elsif %w(scaler slider).include? widget
      Float value.to_s rescue value
    else
      value
    end
  end

  # Casts the default value according to the question's widget.
  #
  # @return the cast default value
  def cast_default_value
    cast_value default_value
  end

  def position
    read_attribute(:position) || _index
  end

private
  def get_options
    if %w(scaler slider).include?(widget) && options.present?
      @minimum_units = options.first.to_f
      @maximum_units = options.last.to_f
      @step = (options[1] - options[0]).round(2)
    elsif %w(checkbox onoff).include?(widget)
      @minimum_units = 0
      @maximum_units = 1
      @step = 1
    elsif %w(checkboxes radio select).include?(widget) && options.present?
      @options_as_list = options.join "\n"
    end
  end

  def set_options
    if %w(scaler slider).include?(widget) && minimum_units.present? && maximum_units.present? && step.present?
      self.options = (BigDecimal(minimum_units.to_s)..BigDecimal(maximum_units.to_s)).step(BigDecimal(step.to_s)).map(&:to_f)
      self.options << maximum_units.to_f unless options.last == maximum_units.to_f
    elsif %w(checkbox onoff).include?(widget)
      self.options = [0, 1]
    elsif %w(checkboxes radio select).include?(widget) && options_as_list.present?
      self.options = options_as_list.split("\n").map(&:strip).reject(&:empty?)
    else
      self.options = nil
    end
  end

  def strip_title
    self.title = title.strip if title?
  end

  def maximum_units_must_be_greater_than_minimum_units
    if %w(scaler slider).include?(widget) && minimum_units.present? && maximum_units.present? && minimum_units.to_f >= maximum_units.to_f
      errors.add :maximum_units, I18n.t('errors.messages.maximum_units_must_be_greater_than_minimum_units')
    end
  end

  def default_value_must_be_between_minimum_and_maximum
    if %w(scaler slider).include?(widget) && minimum_units.present? && maximum_units.present? && default_value.present? && minimum_units.to_f < maximum_units.to_f
      if default_value.to_f < minimum_units.to_f || default_value.to_f > maximum_units.to_f
        errors.add :default_value, I18n.t('errors.messages.default_value_must_be_between_minimum_and_maximum')
      end
    end
  end
end
