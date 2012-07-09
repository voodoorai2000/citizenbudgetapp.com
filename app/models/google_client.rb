# http://code.google.com/p/google-api-ruby-client/wiki/OAuth2
class GoogleClient
  class ConfigurationError < StandardError; end
  class AccessRevokedError < StandardError; end

  attr_reader :client

  # @raises [ConfigurationError] unless configuration variables are set
  def initialize(redirect_uri)
    if ENV['GOOGLE_CLIENT_ID'] && ENV['GOOGLE_CLIENT_SECRET']
      @client = Google::APIClient.new
      @client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
      @client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
      @client.authorization.scope = 'https://www.googleapis.com/auth/analytics.readonly'
      @client.authorization.redirect_uri = redirect_uri
    else
      raise ConfigurationError
    end
  end

  # @return whether the client is authorized
  # @todo make sure this is false if access was revoked
  def authorized?
    client.authorization.access_token && !client.authorization.expired?
  end

  # @param [String] state any string
  # @return [String] an OAuth 2 authorization URI
  # @see https://developers.google.com/accounts/docs/OAuth2WebServer#formingtheurl
  def authorization_uri(state = '')
    client.authorization.authorization_uri(state: state).to_s
  end

  # Redeems an authorization code to obtain an access token.
  # @param [String] code an authorization code
  # @raises [Signet::AuthorizationError] if code exchange fails
  # @see https://github.com/sporkmonger/signet/blob/master/lib/signet/oauth_2/client.rb#L688
  def authorize!(code)
    client.authorization.code = code
    client.authorization.fetch_access_token!
  end

  # Resets the token.
  def unauthorize!
    client.update_token! access_token: nil, refresh_token: nil, expires_in: nil, issued_at: nil
  end

  # Ensures the client has a fresh access token.
  # @raises [Signet::AuthorizationError] if access was revoked
  # @see https://github.com/sporkmonger/signet/blob/master/lib/signet/oauth_2/client.rb#L157
  # @see https://github.com/sporkmonger/signet/blob/master/lib/signet/oauth_2/client.rb#L581
  # @note If access is revoked while the token is fresh, no exception is raised.
  # @note Can revoke access at https://accounts.google.com/b/0/IssuedAuthSubTokens
  def refresh!(options = {})
    client.authorization.update_token! options
    if client.authorization.refresh_token && client.authorization.expired?
      client.authorization.fetch_access_token!
    end
  rescue Signet::AuthorizationError
    unauthorize!
    # Raise an error so that the application knows to expire tokens.
    raise AccessRevokedError
  end

  # @return a data object of the authenticated user's Google Analytics profiles
  # @see https://developers.google.com/apis-explorer/#p/analytics/v3/
  # @note Default max-results is 1000, which we are unlikely to exceed.
  def profiles
    result = client.execute(client.discovered_api('analytics', 'v3').management.profiles.list, accountId: '~all', webPropertyId: '~all')
    if result.status == 200
      result.data
    elsif [400, 401, 403].include? result.status
      unauthorize!
      # Raise an error so that the application knows to expire tokens.
      raise AccessRevokedError
    end
  end

  # @return [Signet::OAuth2::Client]
  def authorization
    client.authorization
  end
end
