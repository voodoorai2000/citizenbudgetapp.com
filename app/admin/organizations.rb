ActiveAdmin.register Organization do
  before_filter { @skip_sidebar = true } # @todo https://github.com/elia/activeadmin-mongoid/pull/11

  # @todo Putting this in ResourceController causes authorization to fail on #index actions.
  controller do
    load_and_authorize_resource :class => resource_class

    # If you don't skip loading on #index you will get the exception:
    # "Collection is not a paginated scope. Set collection.page(params[:page]).per(10) before calling :paginated_collection."
    skip_load_resource :class => resource_class, :only => :index
  end

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
        if can? :create, Questionnaire
          div link_to t(:new_questionnaire), new_admin_questionnaire_path(organization_id: resource.id), class: 'button'
        end
        '@todo https://github.com/gregbell/active_admin/pull/1460'
      end
    end
  end
end
