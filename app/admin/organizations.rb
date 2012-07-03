ActiveAdmin.register Organization do
  controller.authorize_resource
  before_filter { @skip_sidebar = true } # @todo https://github.com/elia/activeadmin-mongoid/pull/11

  index do
    column :name
    column :questionnaires do |o|
      o.questionnaires.count
    end
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :questionnaires do |o|
        ul do
          o.questionnaires.each do |q|
            li auto_link q
          end
        end
        div link_to_if can?(:create, Questionnaire), t(:new_questionnaire), new_admin_questionnaire_path(organization_id: resource.id), class: 'button'
      end
    end
  end
end
