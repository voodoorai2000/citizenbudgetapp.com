ActiveAdmin.register AdminUser do
  before_filter { @skip_sidebar = true } # @todo https://github.com/elia/activeadmin-mongoid/pull/11

  # @todo Putting this in ResourceController causes authorization to fail on #index actions.
  controller do
    load_and_authorize_resource :class => resource_class

    # If you don't skip loading on #index you will get the exception:
    # "Collection is not a paginated scope. Set collection.page(params[:page]).per(10) before calling :paginated_collection."
    skip_load_resource :class => resource_class, :only => :index
  end

  index do
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

  form do |f|
    f.inputs do
      f.input :email
      f.input :organization
      f.input :role, as: :radio, collection: AdminUser::ROLES.map{|r| [t(r, scope: :role), r]}
      f.input :locale, as: :radio, collection: Locale::LOCALES.map{|k,v| [v, k]}
    end
    f.actions
  end

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
