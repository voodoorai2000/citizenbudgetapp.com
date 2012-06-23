class PagesController < ApplicationController
  caches_action :channel, :not_found

  def channel
    expires_in 1.hour, public: true
    render layout: false
  end

  def not_found
    expires_in 1.hour, public: true
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false
  end
end
