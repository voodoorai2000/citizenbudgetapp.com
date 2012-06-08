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
  end
end
