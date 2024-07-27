# frozen_string_literal: true

RSpec.describe 'PumaAfterReply features' do
  before { PumaAfterReply.clear }
  after { PumaAfterReply.clear }

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
      before { PumaAfterReply.config.reset! }
      after { PumaAfterReply.config.reset! }

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

  specify 'reply adding' do
  end
end
