class PagesController < ApplicationController
  caches_action :channel, :not_found

  def channel
    expires_in 1.hour, public: true
    render layout: false
  end

  def oauth2callback
    if params[:code]
      begin
        google_client.authorize! params[:code]
        # Save the refresh token, so that we can get fresh tokens later.
        current_admin_user.update_token! google_client.authorization
      rescue Signet::AuthorizationError # code exchange failure
        flash[:error] = t(:oauth_code_exchange_failure)
      end
    elsif params[:error]
      flash[:error] = t(:oauth_failure)
    end
    redirect_to params[:state] || admin_root_path
  end

  def not_found
    expires_in 1.hour, public: true
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false
  end
end
