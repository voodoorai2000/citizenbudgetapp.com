# http://code.google.com/p/google-api-ruby-client/wiki/OAuth2
# @note Using a JavaScript client, it's impossible for users belonging to the
# same organization to share access to Google Analytics data.
class GoogleApiAuthorization
  include Mongoid::Document

  class CodeExchangeError < StandardError; end
  class AccessRevokedError < StandardError; end
  class APIError < StandardError; end

  embedded_in :questionnaire

  field :token, type: Hash, default: {}

  # @return [Boolean] whether configuration variables are set
  def self.configured?
    ENV['GOOGLE_CLIENT_ID'] && ENV['GOOGLE_CLIENT_SECRET']
  end

  # @return [Boolean] whether configuration variables are set
  def configured?
    self.class.configured?
  end

  # @return [Google::APIClient] a Google API client
  def client
    @client ||= begin
      client = Google::APIClient.new
      client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
      client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
      client.authorization.scope = 'https://www.googleapis.com/auth/analytics.readonly'
      client.authorization.redirect_uri = ENV['GOOGLE_REDIRECT_URI']
      client.authorization.update_token! token
      client
    end
  end

  # @return [Boolean] whether the client is authorized
  def authorized?
    configured? && !!client.authorization.access_token
  end

  # @param [String] state any string
  # @return [String] an authorization URI
  # @see https://developers.google.com/accounts/docs/OAuth2WebServer#formingtheurl
  def authorization_uri(state = '')
    client.authorization.authorization_uri(state: state.to_s).to_s
  end

  # Redeems an authorization code to obtain an access token.
  #
  # @param [String] code an authorization code
  # @raises [CodeExchangeError] if code exchange failed
  # @see https://github.com/sporkmonger/signet/blob/master/lib/signet/oauth_2/client.rb#L688
  def redeem_authorization_code!(code)
    client.authorization.code = code
    fetch_access_token!
  rescue Signet::AuthorizationError
    raise CodeExchangeError
  end

  # Revokes a refresh token.
  #
  # @return [Boolean] if the revocation was successful
  # @see https://developers.google.com/accounts/docs/OAuth2WebServer#tokenrevoke
  # @note Can manually revoke at https://accounts.google.com/b/0/IssuedAuthSubTokens
  def revoke_refresh_token!
    if client.authorization.refresh_token
      result = Faraday.get('https://accounts.google.com/o/oauth2/revoke', token: client.authorization.refresh_token).status == 200
      unauthorize! if result
      result
    end
  end

  # Gets Google Analytics profiles.
  #
  # @see https://developers.google.com/analytics/devguides/config/mgmt/v3/
  def profiles
    execute! api_method: client.discovered_api('analytics', 'v3').management.profiles.list, parameters: { accountId: '~all', webPropertyId: '~all'}
  end

  # Gets Google Analytics report data.
  #
  # @param [Hash] parameters
  # @see https://developers.google.com/analytics/devguides/reporting/core/v3/
  # @see https://developers.google.com/analytics/devguides/reporting/core/dimsmets
  def reports(parameters = {})
    parameters.stringify_keys!
    # Prepend "ga:" to the table ID if absent.
    if parameters['ids'] && parameters['ids'][/\A\d+\z/]
      parameters['ids'] = "ga:#{parameters['ids']}"
    end
    # Allow passing a Time, Date or DateTime.
    %w(start-date end-date).each do |parameter|
      parameters[parameter] = parameters[parameter].strftime '%Y-%m-%d' unless String === parameters[parameter]
    end
    # Allow passing an Array.
    %w(metrics dimensions sort).each do |parameter|
      if Array === parameters[parameter]
        parameters[parameter] = parameters[parameter].map{|value|
          value[':'] ? value : "ga:#{value}"
        }.join(',')
      end
    end

    execute! api_method: client.discovered_api('analytics', 'v3').data.ga.get, parameters: parameters
  end

private

  # Fetches an access token and stores it.
  #
  # @raises [Signet::AuthorizationError] if code exchange failed or if access was revoked
  def fetch_access_token!
    client.authorization.fetch_access_token!
    update_token! client.authorization
  end

  # Ensures the client has a fresh access token.
  #
  # @see https://github.com/sporkmonger/signet/blob/master/lib/signet/oauth_2/client.rb#L157
  # @see https://github.com/sporkmonger/signet/blob/master/lib/signet/oauth_2/client.rb#L581
  def refresh_access_token!
    # If we have no refresh token, we wait for the API to raise an authorization error.
    if client.authorization.expired? && client.authorization.refresh_token
      begin
        fetch_access_token!
      rescue Signet::AuthorizationError
        unauthorize!
      end
    end
  end

  # Deletes the OAuth 2 credentials.
  def unauthorize!
    client.authorization.update_token! access_token: nil, refresh_token: nil, expires_in: nil, issued_at: nil
    delete_token!
  end

  # Stores Google API OAuth 2 credentials.
  # @param [Signet::OAuth2::Client] authorization
  def update_token!(authorization)
    update_attribute :token, {
      access_token: authorization.access_token,
      refresh_token: authorization.refresh_token,
      # #expired_in and #issued_at are required for Google::APIClient#expired?
      # @see https://github.com/sporkmonger/signet/blob/master/lib/signet/oauth_2/client.rb#L581
      expires_in: authorization.expires_in,
      issued_at: authorization.issued_at,
    }
  end

  # Deletes the Google API OAuth 2 credentials.
  def delete_token!
    update_attribute :token, {}
  end

  # Executes an API call from an authorized client.
  #
  # @param [Hash] params
  # @return a data object
  # @raises [AccessRevokedError] if access was revoked
  # @raises [Google::APIClient::ClientError] if a client error occurred
  # @raises [APIError] if a server or transmission error occurred
  # @see https://developers.google.com/apis-explorer/#p/analytics/v3/
  #
  # @note Default max-results is 1000, which we are unlikely to exceed.
  def execute!(params)
    refresh_access_token!
    if authorized?
      client.execute!(params).data
    else
      raise AccessRevokedError
    end
  rescue Google::APIClient::ServerError, Google::APIClient::TransmissionError
    raise APIError
  end
end
