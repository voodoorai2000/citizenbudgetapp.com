ActiveAdmin.register AdminUser do
  index download_links: false do
    column :email
    column :organization
    column :role do |a|
      t(a.role, scope: :role) if a.role?
    end
    column :locale do |a|
      Locale.locale_name(a.locale) if a.locale?
    end
    default_actions
  end

  form partial: 'form'

  show do
    attributes_table do
      row :email
      row :organization
      row :role do |a|
        t(a.role, scope: :role) if a.role?
      end
      row :locale do |a|
        Locale.locale_name(a.locale) if a.locale?
      end
    end
  end
end
