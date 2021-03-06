# Changelog | SSC.Bot

All notable changes to this project will be documented in this file.

Format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning v2.0.0](https://semver.org/spec/v2.0.0.html).

## [[Unreleased]](https://github.com/esotericpig/ssc.bot/compare/v0.2.0...HEAD)
-


## [v0.2.0] - [2021-06-22](https://github.com/esotericpig/ssc.bot/compare/v0.1.1...v0.2.0)
### Changed
- Renamed `SSCBot::SSCFile#get_line()` to `read_uline()` due to RuboCop complaining about using `get_`.
- Formatted all code with RuboCop.
- Formatted all files.
- Updated dev Gems.


## [v0.1.1] - [2020-09-09](https://github.com/esotericpig/ssc.bot/compare/v0.1.0...v0.1.1)

### Added
- `ChatLog::Message`
    - `type_<type>?()` for all `TYPES`
        - `msg.type_chat?(); msg.type_pub?(); msg.type_q_log?()`
    - `self.add_type(type)`

### Changed
- `ChatLog::MessageParser`
    - Refactored & formatted code
    - Added warn message to `parse_q_namelen` if namelen > max

### Fixed
- `Util.u_blank?(str)`


## [v0.1.0] - [2020-08-29](https://github.com/esotericpig/ssc.bot/tree/v0.1.0)

First working version.

### Added
- /
    - .gitignore
    - .yardopts
    - CHANGELOG.md
    - Gemfile
    - LICENSE.txt
    - Rakefile
    - README.md
    - ssc.bot.gemspec
- /lib/
    - ssc.bot.rb
- /lib/ssc.bot/
    - chat_log.rb
    - chat_log_file.rb
    - error.rb
    - ssc_file.rb
    - util.rb
    - version.rb
- /lib/ssc.bot/chat_log/
    - message.rb
    - message_parsable.rb
    - message_parser.rb
    - messages.rb
- /lib/ssc.bot/user/
    - jrobot_message_sender.rb
    - message_sender.rb
- /test/
    - test_helper.rb
