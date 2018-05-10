# frozen_string_literal: true

require 'pastel'
require 'tty-spinner'
require 'tty-table'

require_relative '../command'
require_relative '../fetcher'

module Coinpare
  module Commands
    class Markets < Coinpare::Command
      def initialize(name, options)
        @name = name
        @options = options
        @pastel = Pastel.new
        @spinner = TTY::Spinner.new(':spinner Fetching data...',
                                    format: :dots, clear: true)
      end

      def execute(input: $stdin, output: $stdout)
        @spinner.auto_spin

        to_symbol = fetch_symbol
        response = Fetcher.fetch_top_exchanges_by_pair(
                     @name.upcase, @options['base'].upcase, @options)

        table = setup_table(response["Data"]["Exchanges"], to_symbol)

        @spinner.stop

        output.puts banner
        output.puts table.render(:unicode, padding: [0, 1], alignment: :right)
      ensure
        @spinner.stop
      end

      def fetch_symbol
        prices = Fetcher.fetch_prices(
                   @name.upcase, @options['base'].upcase, @options)
        prices['DISPLAY'][@name.upcase][@options['base'].upcase]['TOSYMBOL']
      end

      def banner
        "\n#{add_color('Coin', :yellow)} #{@name.upcase}  " \
        "#{add_color('Base Currency', :yellow)} #{@options['base'].upcase}  " \
        "#{add_color('Time', :yellow)} #{timestamp}\n\n"
      end

      def setup_table(data, to_symbol)
        table = TTY::Table.new(header: [
          { value: 'Market', alignment: :left },
          'Price',
          'Chg. 24H',
          'Chg.% 24H',
          'Open 24H',
          'High 24H',
          'Low 24H',
          'Direct Vol. 24H',
        ])

        data.each do |market|
          growing = market['CHANGE24HOUR'] > 0
          market_details = [
            { value: add_color(market['MARKET'], :yellow), alignment: :left },
            "#{to_symbol} #{number_to_currency(market['PRICE'].round(2))}",
            add_color("#{pick_arrow(growing)} #{to_symbol} #{number_to_currency(market['CHANGE24HOUR'].round(2))}", pick_color(growing)),
            add_color("#{pick_arrow(growing)} #{percent(market['CHANGEPCT24HOUR'])}%", pick_color(growing)),
            "#{to_symbol} #{number_to_currency(market['OPEN24HOUR'].round(2))}",
            "#{to_symbol} #{number_to_currency(market['HIGH24HOUR'].round(2))}",
            "#{to_symbol} #{number_to_currency(market['LOW24HOUR'].round(2))}",
            "#{to_symbol} #{number_to_currency(market['VOLUME24HOURTO'].round(2))}"
          ]
          table << market_details
        end

        table
      end
    end # Markets
  end # Commands
end # Coinpare
