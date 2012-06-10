ActiveAdmin.register Section do
  belongs_to :questionnaire

  index do
    column :title
    column :questions do |s|
      s.questions.count
    end
    default_actions
  end

  form do |f|
    f.inputs t(:inputs, type: resource_class.model_name.human) do
      f.input :title
    end
    # Need to do this otherwise subform doesn't render.
    resource.questions.build
    f.has_many :questions do |g|
      unless g.object.new_record?
        g.input :_destroy, as: :boolean, label: t(:destroy)
      end
      g.input :title
      g.input :description, as: :text, input_html: {rows: 3}
      g.input :widget, collection: Question::WIDGETS.map{|w| [t(w, scope: :widgets), w]}
      g.input :options
      g.input :unit_amount, as: :string, input_html: {size: 6}
      g.input :unit_name, input_html: {size: 20}
      g.input :minimum_units, input_html: {size: 6}
      g.input :maximum_units, input_html: {size: 6}
      g.input :step, input_html: {size: 6}, default_value: 1
      g.input :default_value, input_html: {size: 6}
      g.input :required
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
