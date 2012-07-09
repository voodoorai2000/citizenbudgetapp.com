# coding: utf-8
ActiveAdmin.register_page 'Dashboard' do
  controller.before_filter :set_locale
  menu priority: 1, label: proc{ I18n.t :dashboard }

  action_item do
    if google_client.authorized?
      link_to t(:deauthorize_google_api), admin_dashboard_deauthorize_google_api_path
    else
      link_to t(:authorize_google_api), google_client.authorization_uri(resource_url)
    end
  end

  page_action :deauthorize_google_api do
    begin
      if google_client.revoke!
        current_admin_user.delete_token!
        flash[:notice] = t(:deauthorize_google_api_success)
      else
        flash[:error] = t(:deauthorize_google_api_failure)
      end
    rescue MissingRefreshToken
      flash[:error] = t(:deauthorize_google_api_blank_token)
    end
    redirect_to admin_root_path
  end

  content title: proc{ I18n.t :dashboard } do
    render 'index'
  end
end
