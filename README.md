<div align="center">
  <img width="207" src="https://github.com/piotrmurach/coinpare/raw/master/assets/coinpare_logo_stacked.png" alt="coinpare logo" />
</div>
<br/>

# Coinpare [![Gitter](https://badges.gitter.im/Join%20Chat.svg)][gitter]

[![Gem Version](https://badge.fury.io/rb/coinpare.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/coinpare.svg?branch=master)][travis]
[![Build status](https://ci.appveyor.com/api/projects/status/dsd3cone86it12pi?svg=true)][appveyor]
[![Maintainability](https://api.codeclimate.com/v1/badges/1072406ba7e951e355e4/maintainability)][codeclimate]
[![Test Coverage](https://api.codeclimate.com/v1/badges/1072406ba7e951e355e4/test_coverage)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/coinpare.svg?branch=master)][inchpages]

[gitter]: https://gitter.im/piotrmurach/coinpare
[gem]: http://badge.fury.io/rb/coinpare
[travis]: http://travis-ci.org/piotrmurach/coinpare
[appveyor]: https://ci.appveyor.com/project/piotrmurach/coinpare
[codeclimate]: https://codeclimate.com/github/piotrmurach/coinpare/maintainability
[coverage]: https://codeclimate.com/github/piotrmurach/coinpare/test_coverage
[inchpages]: http://inch-ci.org/github/piotrmurach/coinpare

> Compare cryptocurrency trading data across multiple exchanges and blockchains in the comfort of your terminal

A screenshot is worth a thousand words:

![CoinsView](https://github.com/piotrmurach/coinpare/raw/master/assets/coinpare_coins.png)

## Installation

This project uses Ruby, before installing the `coinpare` tool, you'll need to ensure Ruby is installed on your machine.

In your terminal execute `ruby` command with `-v` option:

```
$ ruby -v
```

If you have version of Ruby greater than `2.0.0` then you're good to go.

Otherwise, please follow [Installing Ruby](https://www.ruby-lang.org/en/documentation/installation/#apt) to pick best installation method for your operating system.

Once Ruby is installed, install the `coinpare` gem:

```
$ gem install coinpare
```

And then execute `coinpare` to see all available options:

```
$ coinpare
```

## Features

* Compare purchased or top coins trading info(price, vol, open, high, low etc)
* Compare top markets by a trading coin pair
* Create custom portfolio and track your holdings
* Display portfolio in a table or pie chart
* Auto refresh cryptocurrencies info with a configurable time interval

## Contents

* [1. Usage](#1-usage)
* [2. View coins](#2-view-coins)
* [3. View markets](#3-view-markets)
* [4. Create portfolio](#4-create-portfolio)
  * [4.1 Edit coins](#41-edit-coins)
  * [4.2 Add/remove coins](#42-addremove-coins)
  * [4.3 Pie charts](#43-pie-charts)

## 1. Usage

To use all available commands, run the following in your terminal:

```bash
$ coinpare
```

You will be presented with the following interface:

![Interface](https://github.com/piotrmurach/coinpare/raw/master/assets/coinpare_interface.png)

## 2. View coins

You can see top 10 trading info (price, volume, open, high, low etc) of any cyptocurrency in any other currency by executing the following in your terminal:

```bash
$ coinpare coins
```

By default, `USD` is used as the base currency price conversion. You can change this by passing `--base` or `-b` flag:

```bash
$ coinpare coins --base BTC
```

If you wish to see more currencies use `--top` flag:

```bash
$ coinpare coins --top 30
```

Alternatively, you can specify exactly the coins you're interested in by naming them separated by space:

```bash
$ coinpare coins ETH BCH LTC --base btc
```

You can also change the default exchange `CCCAGG` using the `--exchange` or `-e` flag:

```bash
$ coinpare coins BTC ETH --exchange coinbase
```

See [view markets](#3view-markets) for more information on available exchanges.

Finally, if you want to auto refresh data use `--watch` or `-w` flag:

```bash
$ coinpare coins --watch
$ coinpare coins -w
```

You can watch for changes on your preferred cryptocurrencies:

```bash
$ coinpare coins BTC ETH LTC ZEC --watch
```

By default 5 seconds interval is used which you can change by providing a new value after `--watch` flag:

```bash
$ coinpare coins --watch 20   # every 20 seconds
```

To finish watching for changes hold down `Ctrl+C` key combination.

## 3. View markets

You can get top markets by volume for any currency pair. By default 10 top exchanges for the BTC and USD pair by their total volume across all markets in the last 24 hours are displayed.

```bash
$ coinpare markets
```

is equivalent to:

```bash
$ coinpare markets BTC --base USD
```

An example output:

![MarketsView](https://github.com/piotrmurach/coinpare/raw/master/assets/coinpare_markets.png)

To change the pair do:

```bash
$ coinpare markets ETH -b BTC
```

You can specify the number of displayed exchanges with `--top` or `-t` flag:

```bash
$ coinpare markets --top 30
```

To watch for changes use the `--watch` or `-w` flag:

```bash
$ coinpare markets --watch
$ coinpare markets -w
```

To finish watching for changes hold down `Ctrl+C` key combination.

## 4. Create portfolio

There is an easy way for you to keep track of all your investments using the `holdings` command.
When run for the first time, you will be presented with a prompt that will guide you through the portfolio setup and allow you to add as many holdings as you wish.

```bash
$ coinpare holdings
```

The prompt may look:

![CreateHoldings](https://github.com/piotrmurach/coinpare/raw/master/assets/coinpare_create_holdings.png)

### 4.1 Edit coins

All your holdings information will be persisted in your user home directory in a file called `coinpare.toml`. You can edit this file directly using your configured editor by passing the `--edit` flag:

```bash
$ coinpare holdings --edit
```

An example configuration file may look:

```
[[holdings]]
amount = 1.0
name = "BTC"
price = 9000.0

[[holdings]]
amount = 5.0
name = "LTC"
price = 100.0

[[holdings]]
amount = 2.3
name = "BTC"
price = 5000.0

[[holdings]]
amount = 1000.0
name = "TRX"
price = 2.0

[settings]
base = "USD"
color = true
exchange = "CCCAGG"
```

Once configured, any subsequent execution of `holdings` command will display current prices and totals. For example, the before mentioned configuration file may produce the following result:

![ViewHoldings](https://github.com/piotrmurach/coinpare/raw/master/assets/coinpare_holdings.png)

Similar to other commands, if you want to auto refresh data use `--watch` or `-w` flag:

```bash
$ coinpare holdings --watch
$ coinpare holdings -w
```

To finish watching for changes hold down `Ctrl+C` key combination.

### 4.2 Add/remove coins

**Coinpare** allows you to easily add and remove individual coins to and from your holdings portfolio.

To add a coin to your current portfolio use `--add` flag

```bash
$ coinpare holdings --add
```

For example, the following screenshot shows adding an `ETH` coin:

![AddHoldings](https://github.com/piotrmurach/coinpare/raw/master/assets/coinpare_holdings_add.png)

To remove one or more coins from your current portfolio use `--remove` flag:

```bash
$ coinpare holdings --remove
```

You will be presented with a multi select menu that contains all current holdings similar to the one below:

![RemoveHoldings](https://github.com/piotrmurach/coinpare/raw/master/assets/coinpare_holdings_remove.png)

Finally, if you wish to clear all your holdings and start again use `--clear` flag:

```bash
$ coinpare holdings --clear
```

### 4.3 Pie charts

By default holdings are displayed in a table format. Alternatively, you can view your portfolio in a pie chart
using the `--pie` or `-p` option which optionally accepts pie chart radius value:

```bash
$ coinpare holdings --pie
```

An example output:

![HoldingsAsPieChart](https://github.com/piotrmurach/coinpare/raw/master/coinpare_holdings_pie_charts.png)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/coinpare. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Coinpare project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotrmurach/coinpare/blob/master/CODE_OF_CONDUCT.md).

## Credits

All the data is obtained from [CryptoCompare](https://www.cryptocompare.com/api).

## Copyright

Copyright (c) 2018 Piotr Murach. See [GNU Affero General Public License v3.0](LICENSE.txt) for further details.
