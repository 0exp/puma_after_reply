# frozen_string_literal: true

# @api public
# @since 0.1.0
class PumaAfterReply::Middleware
  # @param app [?]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize(app)
    @app = app
  end

  # PumaAfterReply.call integration to the puma's `rack.after_reply` env variable that is used
  # for the "after reply" hook inside the puma's request dispatching.
  #
  # @param env [?]
  # @return [Array]
  #
  # @api private
  # @since 0.1.0
  def call(env)
    @app.call(env).tap do
      # :nocov:
      if env.key?('rack.after_reply')
        env['rack.after_reply'] << proc { PumaAfterReply.call }
      elsif PumaAfterReply::Config.run_anyway
        PumaAfterReply.call # NOTE: may be usefull for/from-inside test environments
      end
      # :nocov:
    end
  end
end
