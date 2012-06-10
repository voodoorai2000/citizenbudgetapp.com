ActiveAdmin.register Organization do
  index do
    column :name
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
        div link_to t(:new_questionnaire), new_admin_questionnaire_path(organization_id: resource.id), class: 'button'
      end
    end
  end
end
