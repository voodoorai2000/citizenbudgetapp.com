# coding: utf-8
ActiveAdmin.register_page 'Dashboard' do
  controller.before_filter :set_locale
  menu priority: 1, label: proc{ I18n.t :dashboard }

  content title: proc{ I18n.t :dashboard } do
    if can? :read, Questionnaire
      columns do
        if current_admin_user.questionnaires.active.count.nonzero?
          column do
            panel t(:active_consultations) do
              ul do
                current_admin_user.questionnaires.active.each do |q|
                  li auto_link(q.organization) + ' – ' + auto_link(q)
                end
              end
            end
          end
        end

        if current_admin_user.questionnaires.future.count.nonzero?
          column do
            panel t(:future_consultations) do
              ul do
                current_admin_user.questionnaires.future.each do |q|
                  li auto_link(q.organization) + ' – ' + auto_link(q)
                end
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
