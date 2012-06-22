class PagesController < ApplicationController
  caches_action :channel, :not_found

  def channel
    render layout: false
  end

  def not_found
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false
  end
end
