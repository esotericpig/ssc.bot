# SSC.Bot

[![Gem Version](https://badge.fury.io/rb/ssc.bot.svg)](https://badge.fury.io/rb/ssc.bot)

[![Source Code](https://img.shields.io/badge/source-github-%23211F1F.svg)](https://github.com/esotericpig/ssc.bot)
[![Changelog](https://img.shields.io/badge/changelog-md-%23A0522D.svg)](CHANGELOG.md)
[![License](https://img.shields.io/github/license/esotericpig/ssc.bot.svg)](LICENSE.txt)

*SSC.Bot* is a simple user bot library for the game [Subspace Continuum](https://store.steampowered.com/app/352700/Subspace_Continuum/).

It's currently in development and only offers limited functionality.

## Contents

- [License](#-license)
- [Setup](#-setup)
- [Using](#-using)
- [Hacking](#-hacking)

## [//](#contents) Setup

Pick your poison...

In your Gemspec (*&lt;project&gt;*.gemspec):

```Ruby
  # Pick one...
  spec.add_runtime_dependency 'ssc.bot', '~> X.X'
  spec.add_development_dependency 'ssc.bot', '~> X.X'
```

In your Gemfile:

```Ruby
  # Pick one...
  gem 'ssc.bot', '~> X.X'
  gem 'ssc.bot', '~> X.X', group: :development
  gem 'ssc.bot', git: 'https://github.com/esotericpig/ssc.bot.git', tag: 'vX.X.X'
```

With the RubyGems package manager:

```
  $ gem install ssc.bot
```

Manually:

```
  $ git clone 'https://github.com/esotericpig/ssc.bot.git'
  $ cd ssc.bot
  $ bundle install
  $ bundle exec rake install:local
```

## [//](#contents) Using

TODO: readme.using

## [//](#contents) Hacking

```
$ git clone 'https://github.com/esotericpig/ssc.bot.git'
$ cd ssc.bot
$ bundle install
$ bundle exec rake -T
```

### Testing

```
$ bundle exec rake test
```

### Generating Doc

```
$ bundle exec rake doc
```

### Installing Locally

```
$ bundle exec rake install:local
```

### Releasing

1. Update *CHANGELOG.md* & *version.rb*
    - `$ raketary bump -v`
2. Check for updates
    - `$ bundle update`
    - `$ bundle outdated`
    - `$ git pull`
3. `$ bundle exec rake release`

## [//](#contents) License

[GNU LGPL v3+](LICENSE.txt)

> SSC.Bot (<https://github.com/esotericpig/ssc.bot>)  
> Copyright (c) 2020 Jonathan Bradley Whited (@esotericpig)  
> 
> SSC.Bot is free software: you can redistribute it and/or modify  
> it under the terms of the GNU Lesser General Public License as published by  
> the Free Software Foundation, either version 3 of the License, or  
> (at your option) any later version.  
> 
> SSC.Bot is distributed in the hope that it will be useful,  
> but WITHOUT ANY WARRANTY; without even the implied warranty of  
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
> GNU Lesser General Public License for more details.  
> 
> You should have received a copy of the GNU Lesser General Public License  
> along with SSC.Bot.  If not, see <https://www.gnu.org/licenses/>.  
