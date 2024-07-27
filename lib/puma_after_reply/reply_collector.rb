# frozen_string_literal: true

# @api private
# @since 0.1.0
class PumaAfterReply::ReplyCollector
  class << self
    # @return [PumaAfterReply::ReplyCollector]
    #
    # @api private
    # @since 0.1.0
    def current
      Thread.current[:puma_after_reply_replies_collector] ||= new
    end
  end

  # @return [Array<#call|Proc>]
  #
  # @api private
  # @since 0.1.0
  attr_reader :inline_replies

  # @return [ARray<#call|Proc>]
  #
  # @api private
  # @since 0.1.0
  attr_reader :threaded_replies

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize
    @inline_replies = []
    @threaded_replies = []
  end

  # @param reply [#call,Proc]
  # @option threaded [Boolean]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def add_reply(reply, threaded:)
    threaded ? threaded_replies << reply : inline_replies << reply
  end

  # @return [Array<#call,Proc>]
  #
  # @api private
  # @since 0.1.0
  def replies
    threaded_replies + inline_replies
  end

  # @return [Integer]
  #
  # @api private
  # @since 0.1.0
  def size
    inline_replies.size + threaded_replies.size
  end

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def threaded__each(&)
    threaded_replies.each(&)
  end

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def threaded__each_and_flush(&)
    threaded_replies.each(&)
  ensure
    threaded_replies.clear
  end

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def inline__each(&)
    inline_replies.each(&)
  end

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def inline__each_and_flush(&)
    inline_replies.each(&)
  ensure
    inline_replies.clear
  end
end
