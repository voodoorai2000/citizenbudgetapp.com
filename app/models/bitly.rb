class Bitly
  class << self
    # @return [Boolean] whether configuration variables are set
    def configured?
      ENV['BITLY_API_KEY'] && ENV['BITLY_LOGIN']
    end

    # Shortens a URL.
    # @param [String] url a url
    # @return [String] a short url
    # @see http://dev.bitly.com/links.html#v3_shorten
    def shorten(url)
      if configured?
        begin
          client.get('/v3/shorten', longUrl: url, login: ENV['BITLY_LOGIN'], apiKey: ENV['BITLY_API_KEY']).body['data']['url']
        rescue # @todo Add exception class.
          url
        end
      else
        url
      end
    end

  private

    # @return [Faraday::Connection] an HTTP client
    def client
      Faraday.new 'https://api-ssl.bitly.com' do |builder|
        builder.request :url_encoded
        builder.response :json
        builder.adapter :net_http
      end
    end
  end
end
