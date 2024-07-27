# frozen_string_literal: true

RSpec.describe 'PumaAfterReply features' do
  describe 'configuration' do
    describe 'config values' do
      specify 'default configs' do
        aggregate_failures 'hash interface' do
          expect(PumaAfterReply.config.to_h).to match({
            fail_on_error: false,
            log_error: nil,
            on_error: nil,
            before_reply: nil,
            after_reply: nil,
            run_anyway: false,
            thread_pool_size: 10
          })
        end

        aggregate_failures 'method interface' do
          expect(PumaAfterReply.config.fail_on_error).to eq(false)
          expect(PumaAfterReply.config.log_error).to eq(nil)
          expect(PumaAfterReply.config.on_error).to eq(nil)
          expect(PumaAfterReply.config.before_reply).to eq(nil)
          expect(PumaAfterReply.config.after_reply).to eq(nil)
          expect(PumaAfterReply.config.run_anyway).to eq(false)
          expect(PumaAfterReply.config.thread_pool_size).to eq(10)
        end
      end
    end

    describe 'customization' do
      before { PumaAfterReply.config.__reset! }
      after { PumaAfterReply.config.__reset! }

      specify 'custom configuration' do
        aggregate_failures 'custom configs' do
          PumaAfterReply.configure do |config|
            config.fail_on_error = true
            config.log_error = proc {}
            config.on_error = proc {}
            config.before_reply = proc {}
            config.after_reply = proc {}
            config.run_anyway = true
            config.thread_pool_size = 50
          end
        end

        aggregate_failures 'new configs (hash variant)' do
          expect(PumaAfterReply.config.to_h).to match({
            fail_on_error: true,
            log_error: be_a(Proc),
            on_error: be_a(Proc),
            before_reply: be_a(Proc),
            after_reply: be_a(Proc),
            run_anyway: true,
            thread_pool_size: 50
          })
        end

        aggregate_failures 'new configs (method variant)' do
          expect(PumaAfterReply.config.fail_on_error).to eq(true)
          expect(PumaAfterReply.config.log_error).to be_a(Proc)
          expect(PumaAfterReply.config.on_error).to be_a(Proc)
          expect(PumaAfterReply.config.before_reply).to be_a(Proc)
          expect(PumaAfterReply.config.after_reply).to be_a(Proc)
          expect(PumaAfterReply.config.run_anyway).to eq(true)
          expect(PumaAfterReply.config.thread_pool_size).to eq(50)
        end
      end
    end
  end

  describe 'reply adding' do
    before do
      PumaAfterReply.clear
      PumaAfterReply.config.__reset!
    end

    after do
      PumaAfterReply.clear
      PumaAfterReply.config.__reset!
    end

    specify 'add and run replies' do
      reply_results = []
      immediate_results = []

      aggregate_failures 'reply accumulation' do
        expect(PumaAfterReply.size).to eq(0)
        expect(PumaAfterReply.replies).to be_empty
        expect(PumaAfterReply.inline_replies).to be_empty
        expect(PumaAfterReply.threaded_replies).to be_empty

        PumaAfterReply.add_reply { reply_results << 1 }
        expect(PumaAfterReply.size).to eq(1)
        expect(PumaAfterReply.replies.size).to eq(1)
        expect(PumaAfterReply.inline_replies.size).to eq(1)
        expect(PumaAfterReply.threaded_replies.size).to eq(0)
        expect(reply_results).to be_empty

        PumaAfterReply.add_reply { reply_results << 2 }
        expect(PumaAfterReply.size).to eq(2)
        expect(PumaAfterReply.replies.size).to eq(2)
        expect(PumaAfterReply.inline_replies.size).to eq(2)
        expect(PumaAfterReply.threaded_replies.size).to eq(0)
        expect(reply_results).to be_empty

        PumaAfterReply.add_reply(threaded: true) { reply_results << 3 }
        expect(PumaAfterReply.size).to eq(3)
        expect(PumaAfterReply.replies.size).to eq(3)
        expect(PumaAfterReply.inline_replies.size).to eq(2)
        expect(PumaAfterReply.threaded_replies.size).to eq(1)
        expect(reply_results).to be_empty

        PumaAfterReply.add_reply(threaded: true) { reply_results << 4 }
        expect(PumaAfterReply.size).to eq(4)
        expect(PumaAfterReply.replies.size).to eq(4)
        expect(PumaAfterReply.inline_replies.size).to eq(2)
        expect(PumaAfterReply.threaded_replies.size).to eq(2)
        expect(reply_results).to be_empty
      end

      aggregate_failures 'conditional replies' do
        PumaAfterReply.cond_reply(false) { immediate_results << :immediate_run1 }
        expect(PumaAfterReply.size).to eq(4)
        expect(PumaAfterReply.replies.size).to eq(4)
        expect(PumaAfterReply.inline_replies.size).to eq(2)
        expect(PumaAfterReply.threaded_replies.size).to eq(2)
        expect(immediate_results).to contain_exactly(:immediate_run1)
        expect(reply_results).to be_empty

        PumaAfterReply.cond_reply(proc { false }) { immediate_results << :immediate_run2 }
        expect(PumaAfterReply.size).to eq(4)
        expect(PumaAfterReply.replies.size).to eq(4)
        expect(PumaAfterReply.inline_replies.size).to eq(2)
        expect(PumaAfterReply.threaded_replies.size).to eq(2)
        expect(immediate_results).to contain_exactly(:immediate_run1, :immediate_run2)
        expect(reply_results).to be_empty

        PumaAfterReply.cond_reply(true) { reply_results << 5 }
        expect(PumaAfterReply.size).to eq(5)
        expect(PumaAfterReply.replies.size).to eq(5)
        expect(PumaAfterReply.inline_replies.size).to eq(3)
        expect(PumaAfterReply.threaded_replies.size).to eq(2)
        expect(immediate_results).to contain_exactly(:immediate_run1, :immediate_run2)
        expect(reply_results).to be_empty

        PumaAfterReply.cond_reply(proc { true }) { reply_results << 6 }
        expect(PumaAfterReply.size).to eq(6)
        expect(PumaAfterReply.replies.size).to eq(6)
        expect(PumaAfterReply.inline_replies.size).to eq(4)
        expect(PumaAfterReply.threaded_replies.size).to eq(2)
        expect(immediate_results).to contain_exactly(:immediate_run1, :immediate_run2)
        expect(reply_results).to be_empty

        PumaAfterReply.cond_reply(proc { true }, threaded: true) { reply_results << 7 }
        expect(PumaAfterReply.size).to eq(7)
        expect(PumaAfterReply.replies.size).to eq(7)
        expect(PumaAfterReply.inline_replies.size).to eq(4)
        expect(PumaAfterReply.threaded_replies.size).to eq(3)
        expect(immediate_results).to contain_exactly(:immediate_run1, :immediate_run2)
        expect(reply_results).to be_empty
      end

      aggregate_failures 'run replies' do
        PumaAfterReply.call

        expect(PumaAfterReply.size).to eq(0)
        expect(PumaAfterReply.replies.size).to eq(0)
        expect(PumaAfterReply.inline_replies.size).to eq(0)
        expect(PumaAfterReply.threaded_replies.size).to eq(0)
        expect(reply_results).to contain_exactly(1, 2, 3, 4, 5, 6, 7)
        expect(immediate_results).to contain_exactly(:immediate_run1, :immediate_run2)
      end
    end

    specify 'hooks' do
      before_replies = []
      after_replies = []
      on_error_results = []
      log_error_results = []

      PumaAfterReply.configure do |config|
        config.fail_on_error = false
        config.before_reply = proc { before_replies << :before }
        config.after_reply = proc { after_replies << :after }
        config.on_error = proc { on_error_results << :on_error }
        config.log_error = proc { log_error_results << :log_error }
      end

      aggregate_failures 'hooking (without errors)' do
        expect(before_replies).to be_empty
        expect(after_replies).to be_empty
        expect(on_error_results).to be_empty
        expect(log_error_results).to be_empty

        PumaAfterReply.add_reply { :some_code }
        PumaAfterReply.call

        expect(before_replies).to contain_exactly(:before)
        expect(after_replies).to contain_exactly(:after)
        expect(on_error_results).to be_empty
        expect(log_error_results).to be_empty
      end

      aggregate_failures 'hooking (with errors)' do
        expect(before_replies).to contain_exactly(:before)
        expect(after_replies).to contain_exactly(:after)
        expect(on_error_results).to be_empty
        expect(log_error_results).to be_empty

        PumaAfterReply.add_reply { raise('test') }
        PumaAfterReply.call

        expect(before_replies).to contain_exactly(:before, :before)
        expect(after_replies).to contain_exactly(:after, :after)
        expect(on_error_results).to contain_exactly(:on_error)
        expect(log_error_results).to contain_exactly(:log_error)
      end

      aggregate_failures 'hook with failings' do
        PumaAfterReply.configure do |config|
          config.fail_on_error = true
        end

        expect(before_replies).to contain_exactly(:before, :before)
        expect(after_replies).to contain_exactly(:after, :after)
        expect(on_error_results).to contain_exactly(:on_error)
        expect(log_error_results).to contain_exactly(:log_error)

        PumaAfterReply.add_reply { raise('test') }
        expect { PumaAfterReply.call }.to raise_error('test')

        expect(before_replies).to contain_exactly(:before, :before, :before)
        expect(after_replies).to contain_exactly(:after, :after, :after)
        expect(on_error_results).to contain_exactly(:on_error, :on_error)
        expect(log_error_results).to contain_exactly(:log_error, :log_error)
      end
    end
  end
end
