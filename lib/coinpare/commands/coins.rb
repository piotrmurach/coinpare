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
    class Coins < Coinpare::Command
      # The default interval for auto updating data
      DEFAULT_INTERVAL = 5

      trap('SIGINT') { exit }

      def initialize(names, options)
        @names = names
        @options = options
        @pastel = Pastel.new
        @timers = Timers::Group.new
        @spinner = TTY::Spinner.new(':spinner Fetching data...',
                                    format: :dots, clear: true)
      end

      def execute(output: $stdout)
        pager = TTY::Pager::BasicPager.new(output: output)
        @spinner.auto_spin

        if @options['watch']
          output.print cursor.hide
          interval = @options['watch'].to_f > 0 ? @options['watch'].to_f : DEFAULT_INTERVAL
          @timers.now_and_every(interval) { display_coins(output, pager) }
          loop { @timers.wait }
        else
          display_coins(output, pager)
        end
      ensure
        @spinner.stop
        if @options['watch']
          @timers.cancel
          output.print cursor.clear_screen_down
          output.print cursor.show
        end
      end

      private

      def display_coins(output, pager)
        if @names.empty? # no coins provided
          @names = setup_top_coins
        end
        response = Fetcher.fetch_prices(@names.map(&:upcase).join(','),
                                        @options['base'].upcase, @options)
        return unless response
        table = setup_table(response['RAW'], response['DISPLAY'])
        @spinner.stop

        lines = 4 + table.rows_size + 3
        clear_output(output, lines) { print_results(table, output, pager) }
      end

      def clear_output(output, lines)
        output.print cursor.clear_screen_down if @options['watch']
        yield if block_given?
        output.print cursor.up(lines) if @options['watch']
      end

      def print_results(table, output, pager)
        output.puts banner(@options)
        pager.page(table.render(:unicode, padding: [0, 1], alignment: :right))
        output.puts
      end

      def setup_top_coins
        response = Fetcher.fetch_top_coins_by_volume(@options['base'].upcase,
                                                     @options)
        return unless response
        response['Data'].map { |coin| coin['CoinInfo']['Name'] }[0...@options['top']]
      end

      def setup_table(raw_data, display_data)
        table = TTY::Table.new(header: [
          { value: 'Coin', alignment: :left },
          'Price',
          'Chg. 24H',
          'Chg.% 24H',
          'Open 24H',
          'High 24H',
          'Low 24H',
          'Direct Vol. 24H',
          'Total Vol. 24H',
          'Market Cap'
        ])

        @names.each do |name|
          coin_data = display_data[name.upcase][@options['base'].upcase]
          coin_raw_data = raw_data[name.upcase][@options['base'].upcase]
          change24h = coin_raw_data['CHANGE24HOUR']
          coin_details = [
            { value: add_color(name.upcase, :yellow), alignment: :left },
            add_color(coin_data['PRICE'], pick_color(change24h)),
            add_color("#{pick_arrow(change24h)} #{coin_data['CHANGE24HOUR']}", pick_color(change24h)),
            add_color("#{pick_arrow(change24h)} #{coin_data['CHANGEPCT24HOUR']}%", pick_color(change24h)),
            coin_data['OPEN24HOUR'],
            coin_data['HIGH24HOUR'],
            coin_data['LOW24HOUR'],
            coin_data['VOLUME24HOURTO'],
            coin_data['TOTALVOLUME24HTO'],
            coin_data['MKTCAP']
          ]
          table << coin_details
        end
        table
      end
    end # Coins
  end # Commands
end # Coinpare
