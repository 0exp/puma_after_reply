# frozen_string_literal: true

module SpecSupport::TestRackApp
  class MinimalRackApp
    # NOTE: respond to any endpoint and http method
    def call(env) = Rack::Response.new(env).finish
  end

  def build_minimal_rack_app(*middlewares)
    Rack::Builder.new do
      use PumaAfterReply::Middleware
      run MinimalRackApp.new
    end
  end

  def make_rack_app_request! = get('/', query_opts: {}, env_opts: {})
end
