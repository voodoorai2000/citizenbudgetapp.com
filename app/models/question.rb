# Keys are based on the Drupal Form API, one of the best thought-out methods
# of describing arbitrary forms.
#
# @see http://api.drupal.org/api/drupal/developer!topics!forms_api_reference.html/7
class Question
  include Mongoid::Document

  embedded_in :section

  # Drupal Form API keys
  field :title, type: String
  field :description, type: String
  field :type, type: String
  field :options, type: String
  field :default_value, type: String
  field :required, type: String

  field :unit_amount, type: String
  field :unit_name, type: String
end
