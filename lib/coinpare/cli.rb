# frozen_string_literal: true

require 'thor'
require 'pastel'
require 'tty-font'

module Coinpare
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    def self.help(*args)
      font =  TTY::Font.new(:standard)
      pastel = Pastel.new
      puts pastel.yellow(font.write("Coinpare"))
      super
    end

    class_option :"no-color", type: :boolean, default: false,
                              desc: 'Disable colorization in output'

    desc 'coins NAMES...', 'Get all the current trading data for the coin names...'
    long_desc <<-DESC
      Get all the current trading info (price, vol, open, high, low etc)
      of any list of cryptocurrencies in any other currency that you need.

      By default 10 top coins by their total volume across all markets in
      the last 24 hours.

      Example:

      > $ coinpare coins BTC ETH --base USD

      Example:

      > $ coinpare coins BTC ETH --exchange coinbase
    DESC
    method_option :base, aliases: '-b', type: :string, default: "USD",
                         desc: 'The currency symbol to convert into',
                         banner: 'currency'
    method_option :columns, aliases: '-c', type: :array,
                            desc: 'Specify columns to display',
                            banner: '0 1 2'
    method_option :exchange, aliases: '-e', type: :string, default: "CCCAGG",
                             desc: 'Name of exchange',
                             banner: 'name'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    method_option :top, aliases: '-t', type: :numeric, default: 10,
                        desc: "The number of top coins by total volume accross all markets in 24 hours"
    method_option :track, type: :array, banner: 'BTC TRX LTC',
                          desc: "Save coins that you wish to track automatically"
    def coins(*names)
      if options[:help]
        invoke :help, ['coins']
      else
        require_relative 'commands/coins'
        Coinpare::Commands::Coins.new(names, options).execute
      end
    end

    desc 'holdings', 'Keep track of all your cryptocurrency investments'
    long_desc <<-DESC
      Get the current trading prices and their change in value and percentage
      for all your cryptocurrency investments.

      Example:

      > $ coinpare holdings

      Example

      > $ coinpare holdings --exchange coinbase --base USD
    DESC
    method_option :add, type: :boolean,
                  desc: "Add a new coin without altering any existhing holdings"
    method_option :base, aliases: '-b', type: :string, default: "USD",
                         desc: 'The currency symbol to convert into',
                         banner: 'currency'
    method_option :edit, type: :string, banner: 'editor',
                         desc: 'Open the holdings configuration file for editing in EDITOR, or the default editor if not specified.'
    method_option :exchange, aliases: '-e', type: :string, default: "CCCAGG",
                             desc: 'Name of exchange',
                             banner: 'name'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    method_option :remove, type: :boolean,
                  desc: "Remove the given coin(s) from holdings"
    method_option :reset, type: :boolean, default: false,
                          desc: 'Remove all coins from your existing holdings'
    def holdings(*)
      if options[:help]
        invoke :help, ['holdings']
      else
        require_relative 'commands/holdings'
        Coinpare::Commands::Holdings.new(options).execute
      end
    end

    desc 'markets [NAME]', 'Get top markets by volume for a currency pair'
    long_desc <<-DESC
      Get top markets by volume for a currency pair.

      By default 10 top markets by their total volume across all markets in
      the last 24 hours.

      Example:

      > $ coinpare markets BTC --base USD

      Example:

      > $ coinpare markets ETH -b BTC
    DESC
    method_option :base, aliases: '-b', type: :string, default: "USD",
                         desc: 'The currency symbol to convert into',
                         banner: 'currency'
    method_option :columns, aliases: '-c', type: :array,
                            desc: 'Specify columns to display',
                            banner: '0 1 2'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    method_option :top, aliases: '-t', type: :numeric, default: 10,
                        desc: "The number of top exchanges by total volume in 24 hours"
    def markets(name = 'BTC')
      if options[:help]
        invoke :help, ['markets']
      else
        require_relative 'commands/markets'
        Coinpare::Commands::Markets.new(name, options).execute
      end
    end

    desc 'version', 'coinpare version'
    def version
      require_relative 'version'
      puts "v#{Coinpare::VERSION}"
    end
    map %w(--version -v) => :version
  end
end
