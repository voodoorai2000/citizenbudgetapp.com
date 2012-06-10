ActiveAdmin.register Section do
  belongs_to :questionnaire

  index do
    column :title
    column :questions do |s|
      s.questions.count
    end
    default_actions
  end

  form namespace: 'foo' do |f|
    f.inputs t(:inputs, type: resource_class.model_name.human) do
      f.input :title
    end
    # @todo there seems to be a bug related to why has_many_form.object is nil
    f.has_many :questions do |g|
      g.input :title
      g.input :description, as: :text, rows: 5
      g.input :type, collection: Question::TYPES
      g.input :widget, collection: Question::WIDGET, include_blank: false
      g.input :options
      #g.input :default_value # @todo column_for_attribute is not called
      g.input :required
      g.input :unit_amount
      g.input :unit_name
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
    end
    resource.questions.each do |q|
      # @todo fill in template
      render 'question'
    end
  end
end
