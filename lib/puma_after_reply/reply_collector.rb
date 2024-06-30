# frozen_string_literal: true

# @api private
# @since 0.1.0
class PumaAfterReply::ReplyCollector
  class << self
    # Each Puma's worker has it's own PumAafterReply::ReplyCollector instance.
    #
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
  # @sicne 0.1.0
  attr_reader :replies

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize
    @replies = []
  end

  # @param reply [#call,Proc]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def add_reply(reply)
    replies << reply
  end

  # @return [Integer]
  #
  # @api private
  # @sicne 0.1.0
  def size
    replies.size
  end

  # @param block [Block]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def each(&block)
    replies.each(&block)
  end

  # @param block [Block]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def each_and_flush(&block)
    each(&block)
  ensure
    replies.clear
  end
end
