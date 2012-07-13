# http://api.rubyonrails.org/classes/ActionController/Caching/Sweeping.html
class QuestionnaireSweeper < ActionController::Caching::Sweeper
  observe Questionnaire, Section
 
  def after_update(record)
    expire_cache_for record
  end
 
  def after_destroy(record)
    expire_cache_for record
  end
 
private

  def expire_cache_for(record)
    questionnaire = record.is_a?(Questionnaire) ? record : record.questionnaire
    expire_action(controller: '/responses', action: ['new', 'show']) # "/" is required to set namespace
  end
end
