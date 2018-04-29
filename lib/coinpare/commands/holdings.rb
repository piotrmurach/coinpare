# frozen_string_literal: true

require 'toml'
require 'pastel'
require 'tty-config'
require 'tty-prompt'
require 'tty-spinner'
require 'tty-table'

require_relative '../command'
require_relative '../fetcher'

module Coinpare
  module Commands
    class Holdings < Coinpare::Command
      def initialize(options)
        @options = options
        @pastel = Pastel.new
        @spinner = TTY::Spinner.new(":spinner Fetching data...",
                                    format: :dots, clear: true)
        config.set('settings', 'base', value: @options['base'])
        config.set('settings', 'color', value: !@options['no-color'])
        config.set('settings', 'exchange', value: @options['exchange'])
      end

      def execute(input: $stdin, output: $stdout)
        config_saved = config.persisted?
        if config_saved && @options['edit']
          editor.open(config.source_file)
          return
        elsif @options['edit']
          output.puts "Sorry, no holdings configuration found."
          output.print "Run \""
          output.print "$ #{add_color('coinpare holdings', :yellow)}\" "
          output.puts "to setup new altfolio."
          return
        end

        config.read if config_saved
        # puts "CONFIG: #{config.to_hash.inspect}"

        holdings = config.fetch('holdings')
        if holdings.nil? || (holdings && holdings.empty?)
          info = setup_portfolio(input, output)
          config.merge(info)
        end
        # Persist current configuration
        config.write(force: true)

        settings = config.fetch('settings')
        # command options take precedence over config settings
        overridden_settings = settings.merge(@options)
        names = config.fetch('holdings').map { |c| c['name'] }

        @spinner.auto_spin
        response = Fetcher.fetch_prices(names.join(','),
                                        settings['base'],
                                        overridden_settings)

        table = setup_table(response['RAW'], response['DISPLAY'])

        @spinner.stop

        output.puts "\n" + add_color('Exchange', :yellow) +
                    " #{overridden_settings['exchange']}  " +
                    add_color('Time', :yellow) + " #{timestamp}\n\n"
        output.puts table.render(:unicode, padding: [0, 1], alignment: :right)
      ensure
        @spinner.stop
      end

      private

      def setup_portfolio(input, output)
        output.puts "Currently you have no investments setup"
        output.puts "Let's change that and setup your altfolio!"
        output.puts

        prompt = TTY::Prompt.new(prefix: "[#{add_color('c', :yellow)}] ",
                                 input: input, output: output,
                                 interrupt: -> { puts; exit 1 },
                                 enable_color: !@options['no-color'])
        base = @options['base']
        exchange = @options['exchange']
        prompt.collect do
          key('settings') do
            key('base').ask('What base currency to convert holdings to?') do |q|
              q.default base
              q.convert ->(b) { b.upcase }
            end
            key('exchange').ask('What exchange would you like to use?') do |q|
              q.default exchange
            end
          end

          while prompt.yes?("Do you want to add coin to your altfolio?")
            key('holdings').values do
              key('name').ask('What coin do you own?') do |q|
                q.default 'BTC'
                q.convert ->(coin) { coin.upcase }
              end
              key('amount').ask('What amount?') do |q|
                q.required true
                q.validate(/[\d.]+/, 'Invalid amount provided')
                q.convert ->(am) { am.to_f }
              end
              key('price').ask('At what price per coin?') do |q|
                q.required true
                q.validate(/[\d.]+/, 'Invalid prince provided')
                q.convert ->(p) { p.to_f }
              end
            end
          end
        end
      end

      def setup_table(raw_data, display_data)
        settings = config.fetch('settings')
        table = TTY::Table.new(header: [
          { value: 'Coin', alignment: :left },
          'Buy Price',
          'Price',
          'Change',
          'Change%'
        ])

        config.fetch('holdings').each do |coin|
          coin_data = raw_data[coin['name']][settings['base']]
          coin_display_data = display_data[coin['name']][settings['base']]
          past_price = coin['amount'] * coin['price']
          curr_price = coin['amount'] * coin_data['PRICE']
          to_symbol = coin_display_data['TOSYMBOL']
          growing = percent_change(coin['price'], curr_price) > 0
          arrow = pick_arrow(growing)

          coin_details = [
            { value: add_color(coin['name'], :yellow), alignment: :left },
            "#{to_symbol} #{past_price.round(2)}",
            add_color("#{to_symbol} #{curr_price.round(2)}", pick_color(growing)),
            add_color("#{arrow} #{to_symbol} #{(curr_price - coin['price']).round(2)}",
                      pick_color(growing)),
            add_color("#{arrow} #{percent_change(coin['price'], curr_price).round(2)}%",
                      pick_color(growing))
          ]
          table << coin_details
        end
        table
      end
    end # Holdings
  end # Commands
end # Coinpare
