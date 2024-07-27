# frozen_string_literal: true

require_relative 'lib/puma_after_reply/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.1'

  spec.name = 'puma_after_reply'
  spec.version = PumaAfterReply::VERSION
  spec.authors = ['Rustam Ibragimov']
  spec.email = ['iamdaiver@gmail.com']

  spec.summary =
    "PumaAfterReply: Puma's \"rack.after_reply\" integration for your Rack-applications."
  spec.description =
    "PumaAfterReply: Puma's \"rack.after_reply\" integration for your Rack-applications. " \
    "Provides #call-able reply abstraction and " \
    "configurable non-threaded/threaded invocation flow " \
    "before/on_error/after hooks for each added reply."

  spec.homepage = 'https://github.com/0exp/puma_after_reply'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/blob/master"
  spec.metadata['changelog_uri']   = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'concurrent-ruby', '~> 1.3'

  spec.add_development_dependency 'armitage-rubocop', '~> 1.59'
  spec.add_development_dependency 'bundler', '>= 2'
  spec.add_development_dependency 'pry', '~> 0.14'
  spec.add_development_dependency 'rake', '~> 13'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'rack', '~> 3.1'
  spec.add_development_dependency 'rack-test', '~> 2.1'
end
