# frozen_string_literal: true

# @api public
# @since 0.1.0
module PumaAfterReply::Config
  class << self
    # @return [Boolean]
    #
    # @api public
    # @since 0.1.0
    attr_accessor :fail_on_error

    # @return [nil,#call,Proc]
    #
    # @api public
    # @since 0.1.0
    attr_accessor :log_error

    # @return [nil,#call,Proc]
    #
    # @api public
    # @since 0.1.0
    attr_accessor :on_error

    # @return [nil,#call,Proc]
    #
    # @api public
    # @since 0.1.0
    attr_accessor :before_reply

    # @return [nil,#call,Proc]
    #
    # @api public
    # @since 0.1.0
    attr_accessor :after_reply

    # @return [Boolean]
    #
    # @api public
    # @since 0.1.0
    attr_accessor :run_anyway

    # @return [Integer]
    #
    # @api public
    # @since 0.1.0
    attr_accessor :thread_count

    # @param configuration [Block]
    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def configure(&configuration)
      instance_eval(&configuration)
    end

    # @return [Hash<Symbol,Any>]
    #
    # @api public
    # @since 0.1.0
    # rubocop:disable Style/EndlessMethod
    def to_h = {
      fail_on_error:,
      log_error:,
      on_error:,
      before_reply:,
      after_reply:,
      run_anyway:
    }
    # rubocop:enable Style/EndlessMethod

    # @return [String]
    #
    # @api public
    # @since 0.1.0
    def to_s = to_h.inspect
  end

  # NOTE: default configs
  self.fail_on_error = false
  self.log_error = nil
  self.on_error = nil
  self.before_reply = nil
  self.after_reply = nil
  self.run_anyway = false
  self.thread_count = 5
end