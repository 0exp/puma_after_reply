# frozen_string_literal: true

# @api private
# @since 0.1.0
module PumaAfterReply::RepliesRunner
  class << self
    # Call all replies in multi-threaded way with a series of hooks (before reply, on error,
    # after reply). Thread count is limited by Concurrent::FixedThreadPool and thread_count config.
    #
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def call
      reply_executions = Concurrent::Array.new
      PumaAfterReply::ReplyCollector.current.each_and_flush do |reply|
        reply_executions << Concurrent::Future.execute({ executor: thread_pool }) do
          call_reply(reply)
        end
      end
      # NOTE:
      #   wait for all replies to be completed (an analogue of Thread#join)
      #   in order to keep busy the current puma worker for the duration of the reply logic
      #   and to prevent any memory bloat;
      reply_executions.each(&:value)
    end

    private

    # Thread pool that is used for threaded reply invocations limited by the thera_count config.
    #
    # @return [Concurrent::FixedThreadPool]
    #
    # @api private
    # @since 0.1.0
    def thread_pool
      Thread.current[:puma_after_reply_runner_thread_pool] ||=
        Concurrent::FixedThreadPool.new(PumaAfterReply::Config.thread_count)
    end

    # Invoke the concrete reply. Invocation flow:
    # => before_reply hook
    # => reply.call
    # => (error hook): log_error hook
    # => (error hook): on_error hook
    # => (error hook): raise if fail_on_error
    # => after_reply hook
    #
    # @param reply [#call,Proc]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def call_reply(reply)
      PumaAfterReply::Config.before_reply&.call
      reply.call
    rescue => error
      PumaAfterReply::Config.log_error&.call(error)
      PumaAfterReply::Config.on_error&.call(error)
      raise(error) if PumaAfterReply::Config.fail_on_error
    ensure
      PumaAfterReply::Config.after_reply&.call(reply)
    end
  end
end
