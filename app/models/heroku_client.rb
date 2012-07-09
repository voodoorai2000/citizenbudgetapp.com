class HerokuClient
  class ConfigurationError < StandardError; end

  class << self
    # @return [Faraday::Connection] an HTTP client for the Heroku API
    # @raises [ConfigurationError] unless configuration variables are set
    def client
      if ENV['HEROKU_API_KEY'] && ENV['HEROKU_APP']
        Faraday.new 'https://api.heroku.com', headers: {'Accept' => 'application/json'} do |builder|
          builder.request :url_encoded
          builder.request :basic_auth, nil, ENV['HEROKU_API_KEY']
          builder.response :json
          builder.adapter :net_http
        end
      else
        raise ConfigurationError
      end
    end

    # Lists the domain names associated to the Heroku app.
    # @return [Array<String>] a list of domain names
    def list_domains
      client.get("/apps/#{ENV['HEROKU_APP']}/domains").body.map{|domain| domain['domain']}
    end

    # Adds a domain name to the Heroku app.
    # @param [String] domain a domain name
    # @return [Boolean] whether domain was added
    def add_domain(domain)
      client.post("/apps/#{ENV['HEROKU_APP']}/domains", domain_name: {domain: domain}).body['domain'] == domain
    end

    # Removes a domain name from the Heroku app.
    # @param [String] domain a domain name
    # @return [Boolean] whether domain was removed
    def remove_domain(domain)
      begin
        client.delete("/apps/#{ENV['HEROKU_APP']}/domains/#{domain}").body == {}
      rescue MultiJson::DecodeError
        false
      end
    end
  end
end
