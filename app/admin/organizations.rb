ActiveAdmin.register Organization do
  index do
    column :name
    default_actions
  end

  form do |f|
    f.inputs t(:inputs, type: resource_class.model_name.human) do
      f.input :name
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row t(:consultations) do |o|
        ul do
          o.questionnaires.each do |q|
            li auto_link q
          end
        end
      end
    end
  end
end
