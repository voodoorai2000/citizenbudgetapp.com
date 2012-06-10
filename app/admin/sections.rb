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
    f.inputs do
      f.input :title
    end

    f.has_many :questions, header: 'Services and activities' do |g|
      unless g.object.new_record?
        g.input :_destroy, as: :boolean
      end
      g.input :title
      g.input :description, as: :text, input_html: {rows: 3}
      g.input :extra, as: :text, input_html: {rows: 3}, wrapper_html: {class: 'bootstrap-popover'}
      g.input :widget, collection: Question::WIDGETS.map{|w| [t(w, scope: :widget), w]}
      g.input :options_as_list
      g.input :unit_amount, as: :string, input_html: {size: 8}
      g.input :unit_name, input_html: {size: 20}
      g.input :minimum_units, input_html: {size: 8}
      g.input :maximum_units, input_html: {size: 8}
      g.input :step, input_html: {size: 8}
      g.input :default_value, input_html: {size: 8}
      g.input :required
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
    end
    resource.questions.each do |q|
      render 'question'
    end
  end
end
