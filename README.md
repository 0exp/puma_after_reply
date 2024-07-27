# puma_after_reply ![build](https://github.com/0exp/puma_after_reply/actions/workflows/build.yml/badge.svg??branch=master)

Puma's "rack.after_reply" integration for your Rack-applications. Provides #call-able reply
abstraction and configurable threaded invocation flow with before/on_error/after hooks for each added reply.

---

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Authors](#authors)

---

### Requirements

<sup>\[[back to top](#table-of-contents)\]</sup>

- `concurrent-ruby` (`~> 1.3`)

---

### Installation

<sup>\[[back to top](#table-of-contents)\]</sup>


```ruby
gem 'puma_after_reply'
```

```shell
bundle install
# --- or ---
gem install puma_after_reply
```

```ruby
require 'puma_after_reply'
```

---

### Configuration

<sup>\[[back to top](#table-of-contents)\]</sup>

---

### Usage

<sup>\[[back to top](#table-of-contents)\]</sup>

**Algorithm**:
- every Puma worker gets own reply collector;
- during the Puma's request your logic adds replies to the worker's reply collector;
- after processing the request Puma's worker returns a response to the browser;
- then Puma's worker launches accumulated replies:
  - threaded replies are launched in separated threads;
  - non-threaded replies are launched sequentially;
- after processing all replies the worker's reply collector is cleared;

Each separated reply is launched according to the following flow:
- **before_reply** hook (`config.before_reply`);
- reply invocation;
- **log_error** hook (`config.log_error`);
- **on_error** hook (`config.on_error`);
- **raise_on_error** fail check (`config.fail_on_error`)
- (ensure): **after_reply** hook (`config.after_reply`);

#### configure:

```ruby
PumaAfterReply.configure do |config|
  # default values:
  config.fail_on_error = false # expects: <Boolean>
  config.log_error = nil # expects: <nil,#call,Proc> (receives: error object)
  config.on_error = nil # expects: <nil,#call,Proc> (receives: error object)
  config.before_reply = nil # expects: <nil,#call,Proc>
  config.after_reply = nil # expects: <nil,#call,Proc>
  config.run_anyway = false # expects: <Boolean>
  config.thread_pool_size = 10 # expects: <Integer>
end
```

```ruby
# and register the middleware (Rails example)
Rails.configuration.middleware.use(PumaAfterReply::Middleware)
```

#### then use in your code (`add_reply`/`cond_reply`):

- non-threaded way (this reply will be processed sequentially):

```ruby
# non-threaded way:
PumaAfterReply.add_reply { your_code }
```

- threaded-way (this reply will be processed in a separated thread):

```ruby
# threaded way:
PumaAfterReply.add_reply(threaded: true) { your_code }
```

- conditional reply adding:
  - `reply(condition, threaded: false, &reply)` (`threaded: false` by default);
  - when condition is `true` - your reply will be pushed to the reply queue;
  - when condition is `false` - your reply will be invoked immediately;
  - supports callable `#call`/`Proc` as a condition value;

```ruby
# - with a boolean value:
PumaAfterReply.cond_reply(!Rails.env.test?) { your_code }
```

```ruby
# with a callabale value:
is_puma_request = proc { check_that_we_are_inside_a_request }
PumaAfterReply.cond_reply(is_puma_request) { your_code }
```

#### some debugging methods:

```ruby
# the count of the added replies:
PumaAfterReply.count
```

```ruby
# replies collections:
PumaAfterReply.replies # all added replies
PumaAfterReply.inline_replies # all added non-threaded replies
PumaAfterReply.threaded_replies # all added threaded replies
```

```ruby
# manual replies running:
PumaAfterReply.call
```

---

## Contributing

<sup>\[[back to top](#table-of-contents)\]</sup>

- Fork it ( https://github.com/0exp/puma_after_reply )
- Create your feature branch (`git checkout -b feature/my-new-feature`)
- Commit your changes (`git commit -am '[feature_context] Add some feature'`)
- Push to the branch (`git push origin feature/my-new-feature`)
- Create new Pull Request

## License

<sup>\[[back to top](#table-of-contents)\]</sup>

Released under MIT License.

## Authors

<sup>\[[back to top](#table-of-contents)\]</sup>

[Rustam Ibragimov](https://github.com/0exp)
