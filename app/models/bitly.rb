class Bitly
  class << self
    # @return [Faraday::Connection] an HTTP client
    def client
      Faraday.new 'https://api-ssl.bitly.com' do |builder|
        builder.request :url_encoded
        builder.response :json
        builder.adapter :net_http
      end
    end

    # Shortens a URL.
    # @see http://dev.bitly.com/links.html#v3_shorten
    def shorten(url)
      begin
        client.get('/v3/shorten', longUrl: url, login: ENV['BITLY_LOGIN'], apiKey: ENV['BITLY_API_KEY']).body['data']['url']
      rescue
        url
      end
    end
  end
end
