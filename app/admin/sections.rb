ActiveAdmin.register Section do
  belongs_to :questionnaire

  index do
    column :title
    column :questions do |s|
      link_to s.questions.count, [:admin, parent, s, :questions]
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
    if resource.questions.empty?
      span link_to t(:new_question), [:new, :admin, resource, :question], class: 'button'
    else
      ul do
        resource.questions.each do |q|
          li auto_link q.title, q
        end
      end
    end
  end
end
