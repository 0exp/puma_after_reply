# frozen_string_literal: true

require 'concurrent-ruby'

# @api public
# @since 0.1.0
module PumaAfterReply
  require_relative 'puma_after_reply/version'
  require_relative 'puma_after_reply/config'
  require_relative 'puma_after_reply/reply_collector'
  require_relative 'puma_after_reply/replies_runner'
  require_relative 'puma_after_reply/middleware'

  class << self
    # Add reply to the reply collector, without any conditions.
    #
    # @option threaded [Boolean]
    # @param reply [Block]
    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def add_reply(threaded: false, &reply)
      ReplyCollector.current.add_reply(reply, threaded:)
    end

    # Add reply to the reply collector condotionally using the boolean factor.
    # If a factor is a callable object - it will be called and the result will be
    # threatet as a factor.
    # If a factor is a true value => your reply block will be added to the replies collector.
    # If a factor is a false value => your reply block will be yielded immediatly.
    #
    # @param factor [Boolean,#call]
    # @option threaded [Boolean]
    # @param reply [Block]
    # @return [void,Any]
    #
    # @pai public
    # @since 0.1.0
    def cond_reply(factor, threaded: false, &reply)
      is_addable = factor.respond_to?(:call) ? factor.call : factor
      is_addable ? add_reply(threaded:, &reply) : yield
    end

    # @param block [Block]
    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def configure(&block)
      Config.configure(&block)
    end

    # @return [PumaAfterReply::Config]
    #
    # @api public
    # @since 0.1.0
    def config
      PumaAfterReply::Config
    end

    # Return the count of currently added replies.
    #
    # @return [Integer]
    #
    # @api public
    # @since 0.1.0
    def count
      ReplyCollector.current.size
    end
    alias_method :size, :count

    # [DEBUGGING METHOD]
    #
    # @return [Array<#call|Proc>]
    #
    # @api private
    # @since 0.1.0
    def replies
      ReplyCollector.current.replies
    end

    # [DEBUGGING METHOD]
    #
    # @return [Array<#call|Proc>]
    #
    # @api private
    # @since 0.1.0
    def inline_replies
      ReplyCollector.current.inline_replies
    end

    # [DEBUGGING METHOD]
    #
    # @return [Array<#call|Proc>]
    #
    # @api private
    # @since 0.1.0
    def threaded_replies
      ReplyCollector.current.threaded_replies
    end

    # [DEBUGGING METHOD]
    #
    # Should not be invoked directly in the business code!
    # Run all currently added replies directly. Imporant: remember that reply collector will
    # be flushed.
    #
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def call
      RepliesRunner.call
    end
    alias_method :run, :call

    # [DEBUGGING METHOD]
    #
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def clear
      ReplyCollector.current.clear
    end
  end
end
