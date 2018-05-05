# frozen_string_literal: true

require 'pastel'
require 'tty-pager'
require 'tty-spinner'
require 'tty-table'

require_relative '../command'
require_relative '../fetcher'

module Coinpare
  module Commands
    class Coins < Coinpare::Command
      def initialize(names, options)
        @names = names
        @options = options
        @pastel = Pastel.new
        @spinner = TTY::Spinner.new(':spinner Fetching data...',
                                    format: :dots, clear: true)
      end

      def execute(output: $stdout)
        @pager = TTY::Pager::BasicPager.new(output: output)
        @spinner.auto_spin

        if @names.empty? # no coins provided
          coins_response = Fetcher.fetch_top_coins_by_volume(@options['base'].upcase, @options)
          top_coins = coins_response['Data']
          @names = top_coins.map { |coin| coin['CoinInfo']['Name'] }[0...@options['top']]
        end

        response = Fetcher.fetch_prices(@names.map(&:upcase).join(','),
                                @options['base'].upcase, @options)

        table = setup_table(response['DISPLAY'])

        @spinner.stop

        output.puts banner(@options)
        @pager.page(table.render(:unicode, padding: [0, 1], alignment: :right))
        output.puts
      ensure
        @spinner.stop
      end

      private

      def setup_table(data)
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
          coin_data = data[name.upcase][@options['base'].upcase]
          growing = !coin_data['CHANGE24HOUR'].include?('-')
          coin_details = [
            { value: add_color(name.upcase, :yellow), alignment: :left },
            add_color(coin_data['PRICE'], pick_color(growing)),
            add_color("#{pick_arrow(growing)} #{coin_data['CHANGE24HOUR']}", pick_color(growing)),
            add_color("#{pick_arrow(growing)} #{coin_data['CHANGEPCT24HOUR']}%", pick_color(growing)),
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
