# frozen_string_literal: true

require 'pastel'
require 'tty-pager'
require 'tty-spinner'
require 'tty-table'
require 'timers'

require_relative '../command'
require_relative '../fetcher'

module Coinpare
  module Commands
    class Markets < Coinpare::Command
      def initialize(name, options)
        @name = name
        @options = options
        @pastel = Pastel.new
        @timers = Timers::Group.new
        @spinner = TTY::Spinner.new(':spinner Fetching data...',
                                    format: :dots, clear: true)
      end

      def execute(input: $stdin, output: $stdout)
        pager = TTY::Pager.new(output: output)
        @spinner.auto_spin

        if @options['watch']
          output.print cursor.hide
          interval = @options['watch'].to_f > 0 ? @options['watch'].to_f : DEFAULT_INTERVAL
          @timers.now_and_every(interval) { display_markets(output, pager) }
          loop { @timers.wait }
        else
          display_markets(output, pager)
        end
      ensure
        @spinner.stop
        if @options['watch']
          @timers.cancel
          output.print cursor.clear_screen_down
          output.print cursor.show
        end
      end

      def display_markets(output, pager)
        to_symbol = fetch_symbol
        response = Fetcher.fetch_top_exchanges_by_pair(
                     @name.upcase, @options['base'].upcase, @options)
        return unless response
        table = setup_table(response["Data"]["Exchanges"], to_symbol)

        lines = banner.lines.size + 1 + table.rows_size + 3
        @spinner.stop
        clear_output(output, lines) { print_results(table, output, pager) }
      end

      def clear_output(output, lines)
        output.print cursor.clear_screen_down if @options['watch']
        yield if block_given?
        output.print cursor.up(lines) if @options['watch']
      end

      def print_results(table, output, pager)
        output.puts banner
        lines = banner.lines.size + 1 + (table.rows_size + 3)
        rendered = table.render(:unicode, padding: [0, 1], alignment: :right)
        if lines >= screen.height
          pager.page rendered
        else
          output.print rendered
        end
        output.puts
      end

      def fetch_symbol
        prices = Fetcher.fetch_prices(
                   @name.upcase, @options['base'].upcase, @options)
        return unless prices
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
          change24h = market['CHANGE24HOUR']
          market_details = [
            { value: add_color(market['MARKET'], :yellow), alignment: :left },
            add_color("#{to_symbol} #{number_to_currency(round_to(market['PRICE']))}", pick_color(change24h)),
            add_color("#{pick_arrow(change24h)} #{to_symbol} #{number_to_currency(round_to(change24h))}", pick_color(change24h)),
            add_color("#{pick_arrow(change24h)} #{round_to(market['CHANGEPCT24HOUR'] * 100)}%", pick_color(change24h)),
            "#{to_symbol} #{number_to_currency(round_to(market['OPEN24HOUR']))}",
            "#{to_symbol} #{number_to_currency(round_to(market['HIGH24HOUR']))}",
            "#{to_symbol} #{number_to_currency(round_to(market['LOW24HOUR']))}",
            "#{to_symbol} #{number_to_currency(round_to(market['VOLUME24HOURTO']))}"
          ]
          table << market_details
        end

        table
      end
    end # Markets
  end # Commands
end # Coinpare
