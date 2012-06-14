class ParseJson < Faraday::Response::Middleware
  dependency do
    require 'oj'
    require 'multi_json'
  end

  def parse(body)
    MultiJson.load body
  end
end

Faraday::Response.register_middleware json: ParseJson
