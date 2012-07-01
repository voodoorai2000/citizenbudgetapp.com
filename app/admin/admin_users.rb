ActiveAdmin.register AdminUser do
  menu if: proc{ can? :manage, AdminUser }
  controller.authorize_resource
  before_filter { @skip_sidebar = true }

  index do
    column :email
    column :locale do |a|
      Locale.locale_name(a.locale) if a.locale?
    end
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :locale, as: :radio, collection: Locale::LOCALES.map{|k,v| [v, k]}
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      row :locale do |a|
        Locale.locale_name(a.locale) if a.locale?
      end
    end
  end
end
