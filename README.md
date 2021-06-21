# SSC.Bot

[![Gem Version](https://badge.fury.io/rb/ssc.bot.svg)](https://badge.fury.io/rb/ssc.bot)

[![Source Code](https://img.shields.io/badge/source-github-%23211F1F.svg)](https://github.com/esotericpig/ssc.bot)
[![Changelog](https://img.shields.io/badge/changelog-md-%23A0522D.svg)](CHANGELOG.md)
[![License](https://img.shields.io/github/license/esotericpig/ssc.bot.svg)](LICENSE.txt)

*SSC.Bot* is a simple user bot library for the game [Subspace Continuum](https://store.steampowered.com/app/352700/Subspace_Continuum/).

It's currently in development and only offers limited functionality.

## Contents

- [Using](#-using)
- [Hacking](#-hacking)
- [License](#-license)

## [//](#contents) Using

Gem name: `ssc.bot`

See [SSC.Nob](https://github.com/esotericpig/ssc.nob) for example usage.

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

1. Check for updates
    - `$ git pull`
    - `$ bundle update`
    - `$ bundle outdated`
2. Update *CHANGELOG.md* & *version.rb*
    - `$ raketary bump -v`
    - `$ raketary bump --patch`
    - `$ bundle update`
3. Release to *GitHub* & *GitHub Packages*
    - `$ bundle exec rake clobber build`
    - `$ gh release create v0.0.0 pkg/*.gem`
    - `$ git fetch --tags origin`
    - `$ raketary github_pkg`
4. Release to *RubyGems*
    - `$ bundle exec rake release`

## [//](#contents) License

[GNU LGPL v3+](LICENSE.txt)

> SSC.Bot (<https://github.com/esotericpig/ssc.bot>)  
> Copyright (c) 2020-2021 Jonathan Bradley Whited  
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
