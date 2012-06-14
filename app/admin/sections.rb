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
      f.input :description, as: :text, input_html: {rows: 3}
      f.input :extra, as: :text, input_html: {rows: 3}
    end

    f.has_many :questions, header: 'Services and activities' do |g|
      unless g.object.new_record?
        g.input :_destroy, as: :boolean
      end
      g.input :title
      g.input :description, as: :text, input_html: {rows: 3}
      g.input :extra, as: :text, input_html: {rows: 3}
      g.input :widget, collection: Question::WIDGETS.map{|w| [t(w, scope: :widget), w]}
      g.input :options_as_list#, as: :text, input_html: {rows: 5}
      g.input :unit_amount, as: :string, input_html: {size: 8}
      g.input :unit_name, input_html: {size: 20}
      g.input :minimum_units, input_html: {size: 8}
      g.input :maximum_units, input_html: {size: 8}
      g.input :step, input_html: {size: 8}
      g.input :default_value, input_html: {size: 8}
      g.input :required
      g.input :position, as: :hidden
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :questions do |s|
        ul(class: 'sortable') do
          s.questions.each do |q|
            li(id: dom_id(q)) do
              i(class: 'icon-move') + span(q.title)
            end
          end
        end
      end
    end
  end

  member_action :sort, method: :post do
    resource.questions.each do |q|
      q.update_attribute :position, params[:question].index(q.id.to_s)
    end
    render nothing: true, status: 204
  end
end
