# Coinpare [![Gitter](https://badges.gitter.im/Join%20Chat.svg)][gitter]

[![Gem Version](https://badge.fury.io/rb/coinpare.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/coinpare.svg?branch=master)][travis]
[![Maintainability](https://api.codeclimate.com/v1/badges/1072406ba7e951e355e4/maintainability)][codeclimate]
[![Test Coverage](https://api.codeclimate.com/v1/badges/1072406ba7e951e355e4/test_coverage)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/coinpare.svg?branch=master)][inchpages]

[gitter]: https://gitter.im/piotrmurach/coinpare
[gem]: http://badge.fury.io/rb/coinpare
[travis]: http://travis-ci.org/piotrmurach/coinpare
[codeclimate]: https://codeclimate.com/github/piotrmurach/coinpare/maintainability
[coverage]: https://codeclimate.com/github/piotrmurach/coinpare/test_coverage
[inchpages]: http://inch-ci.org/github/piotrmurach/coinpare

> Compare cryptocurrency trading data across multiple exchanges and blockchains in the comfort of your terminal window.

A screenshot is worth a thousand words:

![Interface](https://github.com/piotrmurach/coinpare/raw/master/assets/coinpare_coins.png)

## Installation

This project uses Ruby, before installing the `coinpare` tool, you'll need to ensure Ruby is installed on your machine.

In your terminal execute `ruby` command with `-v` option:

```
$ ruby -v
```

If you have version of Ruby greater than `2.0.0` then you're good to go.

Otherwise, please follow [Installing Ruby](https://www.ruby-lang.org/en/documentation/installation/#apt) to pick best installation method.

Once Ruby is installed, install the `coinpare` gem:

```
$ gem install coinpare
```

And then execute `coinpare` to see all available options:

```
$ coinpare
```

## Features

* Compare chosen or top coins by trading volume
* Compare top markets by a trading coin pair
* Create your custom portfolio
* Compare valuations for your chosen holdings

## Usage

To use all available commands run:

```bash
$ coinpare
```

## View coins

You can see top 10 trading info (price, volume, open, high, low etc) of any cyptocurrency in any other currency by running:

```bash
$ coinpare coins
```

By default, `USD` is used as the base currency price which you can change by passing `--base` or `-b` flag:

```bash
$ coinpare coins --base BTC
```

If you wish to see more currencies use `--top` flag:

```bash
$ coinpare coins --top 30
```

Alternatively, you can specify exactly the coins you're interested in by naming them :

```bash
$ coinpare coins ETH BCH LTC --base btc
```

You can also change the default exchange:

```bash
$ coinpare coins BTC ETH --exchnage coinbase
```

See (markets)[] for more information

## View markets

## Create portfolio

### Add/remove coins

**Coinpare** allows you to easily add and remove individual coins to and from your holdings portfolio.

To add a coin do

```bash
$ coinpare holdings --add
```

```bash
$ coinpare holdings --remove
```

For example, the following screenshot shows adding a 'ETH' coin:

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/coinpare. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Coinpare project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/coinpare/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2018 Piotr Murach. See [GNU Affero General Public License v3.0](LICENSE.txt) for further details.
