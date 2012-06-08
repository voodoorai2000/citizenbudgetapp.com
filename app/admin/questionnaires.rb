ActiveAdmin.register Questionnaire do
  scope :active
  scope :future
  scope :past

  index do
    column :organization do |q|
      auto_link q.organization
    end
    column t(:starts_at) do |q|
      l(q.starts_at, format: :long) if q.starts_at?
    end
    column t(:ends_at) do |q|
      l(q.ends_at, format: :long) if q.ends_at?
    end
    column :sections do |q|
      link_to q.sections.count, [:admin, q, :sections]
    end
    default_actions
  end

  form do |f|
    f.inputs t(:inputs, type: resource_class.model_name.human) do
      f.input :organization_id, as: :select, collection: Organization.all.map{|o| [o.name, o.id]}
      f.input :starts_at, as: :datetime, end_year: Time.now.year + 1, prompt: true, include_blank: false
      f.input :ends_at, as: :datetime, end_year: Time.now.year + 1, prompt: true, include_blank: false
    end
    f.actions
  end

  show do
    attributes_table do
      row :organization do |q|
        auto_link q.organization
      end
      row t(:starts_at) do |q|
        l(q.starts_at, format: :long) if q.starts_at?
      end
      row t(:ends_at) do |q|
        l(q.ends_at, format: :long) if q.ends_at?
      end
    end
    if resource.sections.empty?
      span link_to t(:new_section), [:new, :admin, resource, :section], class: 'button'
    else
      ul do
        resource.sections.each do |s|
          li link_to s.title, [:admin, resource, s]
        end
      end
    end
  end
end
