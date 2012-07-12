ActiveAdmin.register Organization do
  index download_links: false do
    column :name
    column :questionnaires do |o|
      link_to_if can?(:read, Questionnaire), o.questionnaires.count, [:admin, :questionnaires]
    end
    default_actions
  end

  form partial: 'form'

  show do
    attributes_table do
      row :name
      row :questionnaires do |o|
        if o.questionnaires.count.nonzero?
          ul do
            o.questionnaires.each do |q|
              li auto_link q
            end
          end
        end
        if can? :create, Questionnaire
          div link_to t(:new_questionnaire), new_admin_questionnaire_path(organization_id: resource.id), class: 'button'
        end
        '@todo https://github.com/gregbell/active_admin/pull/1479'
      end
    end
  end
end
