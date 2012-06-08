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
    f.has_many :questions do |g|
      g.input :title
      # @todo
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
    end
    # @todo show questions
  end
end
