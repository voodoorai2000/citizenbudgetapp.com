# coding: utf-8
ActiveAdmin.register_page "Dashboard" do
  menu :priority => 1

  content do
    columns do
      if Questionnaire.active.count.nonzero?
        column do
          panel t(:active_consultations) do
            ul do
              Questionnaire.includes(:organization).active.each do |q|
                li auto_link(q.organization) + ' – ' + auto_link(q)
              end
            end
          end
        end
      end

      if Questionnaire.future.count.nonzero?
        column do
          panel t(:future_consultations) do
            ul do
              Questionnaire.includes(:organization).future.each do |q|
                li auto_link(q.organization) + ' – ' + auto_link(q)
              end
            end
          end
        end
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
