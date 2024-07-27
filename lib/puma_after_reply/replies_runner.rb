# frozen_string_literal: true

# @api private
# @since 0.1.0
module PumaAfterReply::RepliesRunner
  class << self
    # @api private
    # @since 0.1.0
    def call
      threaded_executions = execute_threaded
      execute_inline
      # NOTE:
      #   wait for all replies to be completed (an analogue of Thread#join)
      #   in order to keep busy the current puma worker for the duration of the reply logic
      #   and to prevent any memory bloat;
      threaded_executions.each(&:value)
    end

    private

    # @return [Concurrent::Array]
    #
    # @api private
    # @since 0.1.0
    def execute_threaded
      Concurrent::Array.new.tap do |reply_executions|
        PumaAfterReply::ReplyCollector.current.threaded__each_and_flush do |reply|
          reply_executions << Concurrent::Future.execute({ executor: thread_pool }) do
            call_reply(reply)
          end
        end
      end
    end

    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def execute_inline
      PumaAfterReply::ReplyCollector.current.inline__each_and_flush do |reply|
        call_reply(reply)
      end
    end

    # @return [Concurrent::FixedThreadPool]
    #
    # @api private
    # @since 0.1.0
    def thread_pool
      Thread.current[:puma_after_reply_runner_thread_pool] ||=
        Concurrent::FixedThreadPool.new(PumaAfterReply::Config.thread_pool_size)
    end

    # @param reply [#call,Proc]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def call_reply(reply)
      PumaAfterReply::Config.before_reply&.call
      reply.call
    rescue => error
      # :nocov:
      # NOTE: it is covered in specs but still showed as "uncovered"
      PumaAfterReply::Config.log_error&.call(error)
      PumaAfterReply::Config.on_error&.call(error)
      # :nocov:
      raise(error) if PumaAfterReply::Config.fail_on_error
    ensure
      PumaAfterReply::Config.after_reply&.call(reply)
    end
  end
end
