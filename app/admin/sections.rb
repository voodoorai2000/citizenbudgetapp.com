ActiveAdmin.register Section do
  belongs_to :questionnaire

  # CanCan has trouble with embedded documents, so we may need to load and
  # authorize resources manually. In this case, we will authorize against
  # the top-level document.
  # @see https://github.com/ryanb/cancan/issues/319
  #
  # Since sections are scoped to the parent questionnaire, we don't necessarily
  # need to use #accessible_by to enforce constraints.
  #
  # https://github.com/ryanb/cancan/wiki/Controller-Authorization-Example
  controller do
    skip_authorize_resource :only => :index

    def index
      authorize! :show, parent
      index!
    end
  end

  index do
    column :title
    column :group do |s|
      t(s.group, scope: :group) if s.group?
    end
    column :questions do |s|
      s.questions.count
    end
    default_actions
  end

  form partial: 'form'

  show do
    attributes_table do
      row :title
      row :group do |s|
        t(s.group, scope: :group) if s.group?
      end
      row :description do |s|
        RDiscount.new(s.description).to_html.html_safe if s.description?
      end
      row :extra do |s|
        RDiscount.new(s.extra).to_html.html_safe if s.extra?
      end
      row :embed do |s|
        s.embed.html_safe if s.embed?
      end
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
