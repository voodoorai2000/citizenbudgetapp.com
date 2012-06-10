ActiveAdmin.register Questionnaire do
  scope :active
  scope :future
  scope :past

  index do
    column :organization do |q|
      auto_link q.organization
    end
    column :starts_at do |q|
      l(q.starts_at, format: :long) if q.starts_at?
    end
    column :ends_at do |q|
      l(q.ends_at, format: :long) if q.ends_at?
    end
    column :sections do |q|
      link_to q.sections.count, [:admin, q, :sections]
    end
    default_actions
  end

  form do |f|
    if params[:organization_id]
      resource.organization_id ||= params[:organization_id]
    end
    f.inputs do
      f.input :organization_id, collection: Organization.all.map{|o| [o.name, o.id]}
      f.input :starts_at, end_year: Time.now.year + 1, prompt: true, include_blank: false
      f.input :ends_at, end_year: Time.now.year + 1, prompt: true, include_blank: false
    end
    f.actions
  end

  show do
    attributes_table do
      row :organization do |q|
        auto_link q.organization
      end
      row :starts_at do |q|
        l(q.starts_at, format: :long) if q.starts_at?
      end
      row :ends_at do |q|
        l(q.ends_at, format: :long) if q.ends_at?
      end
      row :sections do |q|
        ul do
          q.sections.each do |s|
            li link_to s.title, [:admin, resource, s]
          end
        end
        div link_to t(:new_section), [:new, :admin, resource, :section], class: 'button'
      end
    end
    # @todo update to display preview of questionnaire
  end
end
