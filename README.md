# puma_after_reply ![build](https://github.com/0exp/puma_after_reply/actions/workflows/build.yml/badge.svg??branch=master)

Puma's "rack.after_reply" integration for your Rack-applications.
Provides configurable threaded invocation flow with before/on_error/after hooks for each added reply.

---

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
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
