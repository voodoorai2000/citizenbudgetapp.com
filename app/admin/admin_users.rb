ActiveAdmin.register AdminUser do
  index do
    column :email
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :email
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
    end
  end
end
