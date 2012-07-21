ActiveAdmin.register Questionnaire do
  scope :current
  scope :future
  scope :past

  action_item only: :show do
    if resource.google_api_authorization.authorized? && resource.domain?
      link_to t(:link_google_analytics), link_google_analytics_admin_questionnaire_path(resource), method: :post
    end
  end

  action_item only: :show do
    if resource.google_api_authorization.configured?
      if resource.google_api_authorization.authorized?
        link_to t(:deauthorize_google_api), deauthorize_google_api_admin_questionnaire_path(resource), method: :post
      else
        link_to t(:authorize_google_api), resource.google_api_authorization.authorization_uri(resource.id)
      end
    end
  end

  member_action :link_google_analytics, method: :post do
    if resource.google_api_authorization.authorized? && resource.domain?
      begin
        data = resource.google_api_authorization.profiles
        profile = data.items.find{|item| Questionnaire.sanitize_domain(item.name) == resource.domain}
        if profile
          resource.update_attributes google_analytics: profile.webPropertyId, google_analytics_profile: profile.id
          flash[:notice] = t(:link_google_analytics_success, property: profile.webPropertyId)
        else
          flash[:error] = t(:link_google_analytics_failure, username: data.username)
        end
      rescue GoogleApiAuthorization::AccessRevokedError
        flash[:error] = t('google_api.access_revoked')
      rescue GoogleApiAuthorization::APIError
        flash[:error] = t('google_api.api_error')
      end
    end # fails silently if conditions before clicking the button fail
    redirect_to resource_path
  end

  member_action :deauthorize_google_api, method: :post do
    if resource.google_api_authorization.authorized?
      if resource.google_api_authorization.revoke_refresh_token!
        flash[:notice] = t(:deauthorize_google_api_success)
      else
        flash[:error] = t('google_api.api_error')
      end
    end # fails silently if conditions before clicking the button fail
    redirect_to resource_path
  end

  member_action :sort, method: :post do
    authorize! :update, resource
    resource.sections.each do |s|
      s.update_attribute :position, params[:section].index(s.id.to_s)
    end
    render nothing: true, status: 204
  end

  index download_links: false do
    column :title
    column :organization do |q|
      auto_link q.organization
    end
    column :starts_at do |q|
      l(q.starts_at.in_time_zone(q.time_zone), format: :short) if q.starts_at?
    end
    column :ends_at do |q|
      l(q.ends_at.in_time_zone(q.time_zone), format: :short) if q.ends_at?
    end
    column :sections do |q|
      link_to_if can?(:read, Section), q.sections.count, [:admin, q, :sections]
    end
    default_actions
  end

  form partial: 'form'

  show title: ->(q){truncate display_name(q), length: 35, separator: ' '} do
    attributes_table do
      row :title
      row :organization do |q|
        auto_link q.organization
      end
      row :locale do |q|
        Locale.locale_name(q.locale) if q.locale?
      end
      row :logo do |q|
        link_to(image_tag(q.logo.large.url), q.logo_url) if q.logo?
      end
      row :title_image do |q|
        link_to(image_tag(q.title_image.square.url), q.title_image_url) if q.title_image?
      end
      row :description
      row :starts_at do |q|
        l(q.starts_at.in_time_zone(q.time_zone), format: :long) if q.starts_at?
      end
      row :ends_at do |q|
        l(q.ends_at.in_time_zone(q.time_zone), format: :long) if q.ends_at?
      end
      row :time_zone do |q|
        TimeZoneI18n[q.time_zone].human if q.time_zone?
      end
      row :introduction do |q|
        RDiscount.new(q.introduction).to_html.html_safe if q.introduction?
      end
      row :domain do |q|
        link_to(q.domain, q.domain_url) if q.domain?
      end
      row :google_analytics
      row :google_analytics_profile
      row :twitter_screen_name
      row :twitter_text
      row :twitter_share_text
      row :facebook_app_id
      row :reply_to do |q|
        mail_to(q.reply_to) if q.reply_to?
      end
      row :thank_you_template do |q|
        if q.thank_you_template?
          simple_format Mustache.render(q.thank_you_template, name: t(:example_name), url: 'http://example.com/xxxxxx')
        end
      end
      row :email_required do |q|
        if q.email_required?
          t :yes
        else
          t :no
        end
      end
      row :sections do |q|
        if q.sections.present?
          ul(class: can?(:update, q) ? 'sortable' : '') do
            q.sections.each do |s|
              li(id: dom_id(s)) do
                if can?(:update, s)
                  i(class: 'icon-move')
                end
                text_node link_to_if can?(:read, s), s.title, [:admin, q, s]
              end
            end
          end
        end
        if can? :create, Section
          div link_to t(:new_section), [:new, :admin, q, :section], class: 'button'
        end
        '@todo https://github.com/gregbell/active_admin/pull/1479'
      end
    end
  end
end
