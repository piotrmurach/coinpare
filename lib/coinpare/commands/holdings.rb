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

        holdings = config.fetch('holdings')
        if holdings.nil? || (holdings && holdings.empty?)
          info = setup_portfolio(input, output)
          config.merge(info)
        elsif @options['add']
          coin_info = add_coin(input, output)
          config.append(coin_info, to: ['holdings'])
        elsif @options['remove']
          coin_info = remove_coin(input, output)
          config.remove(*coin_info, from: ['holdings'])
        end

        holdings = config.fetch('holdings')
        no_holdings_left = holdings.nil? || (holdings && holdings.empty?)
        if no_holdings_left
          config.delete('holdings')
        end

        # Persist current configuration
        config.write(force: true)
        if no_holdings_left
          output.puts add_color("Please add holdings to your altfolio!", :green)
          return
        end

        settings = config.fetch('settings')
        # command options take precedence over config settings
        overridden_settings = settings.merge(@options)
        holdings = config.fetch('holdings') { [] }
        names = holdings.map { |c| c['name'] }

        @spinner.auto_spin
        response = Fetcher.fetch_prices(names.join(','),
                                        settings['base'],
                                        overridden_settings)

        return unless response
        table = setup_table(response['RAW'], response['DISPLAY'])

        @spinner.stop

        output.puts banner(overridden_settings)
        output.puts table.render(:unicode, padding: [0, 1], alignment: :right)
      ensure
        @spinner.stop
      end

      def create_prompt(input, output)
        prompt = TTY::Prompt.new(
          prefix: "[#{add_color('c', :yellow)}] ",
          input: input, output: output,
          interrupt: -> { puts; exit 1 },
          enable_color: !@options['no-color'], clear: true)
        prompt.on(:keypress) { |e| prompt.trigger(:keydown) if e.value == 'j' }
        prompt
      end

      def ask_coin
        -> (prompt) do
          key('name').ask('What coin do you own?') do |q|
            q.required true
            q.default 'BTC'
            q.validate(/\w{2,}/, 'Currency can only be chars.')
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

      def add_coin(input, output)
        prompt = create_prompt(input, output)
        context = self
        data = prompt.collect(&context.ask_coin)
        output.print cursor.up(3)
        output.print cursor.clear_screen_down
        data
      end

      def remove_coin(input, output)
        prompt = create_prompt(input, output)
        holdings = config.fetch('holdings')
        data = prompt.multi_select('Which hodlings to remove?') do |menu|
          holdings.each do |holding|
            menu.choice "#{holding['name']} (#{holding['amount']})", holding
          end
        end
        output.print cursor.up(1)
        output.print cursor.clear_line
        data
      end

      def setup_portfolio(input, output)
        output.puts "Currently you have no investments setup"
        output.puts "Let's change that and setup your altfolio!"
        output.puts

        prompt = create_prompt(input, output)
        context = self
        base = @options['base']
        exchange = @options['exchange']

        data = prompt.collect do
          key('settings') do
            key('base').ask('What base currency to convert holdings to?') do |q|
              q.default base
              q.convert ->(b) { b.upcase }
              q.validate(/\w{3}/, 'Currency code needs to be 3 chars long')
            end
            key('exchange').ask('What exchange would you like to use?') do |q|
              q.default exchange
            end
          end

          while prompt.yes?("Do you want to add coin to your altfolio?")
            key('holdings').values(&context.ask_coin)
          end
        end

        lines = 3 + # intro
                2 + # base + exchange
                data['holdings'].size * 4 + 1
        output.print cursor.up(lines)
        output.print cursor.clear_screen_down

        data
      end

      def setup_table(raw_data, display_data)
        settings = config.fetch('settings')
        total_buy = 0
        total = 0
        to_symbol = nil
        table = TTY::Table.new(header: [
          { value: 'Coin', alignment: :left },
          'Amount',
          'Price',
          'Total Price',
          'Cur. Price',
          'Total Cur. Price',
          'Change',
          'Change%'
        ])

        config.fetch('holdings').each do |coin|
          coin_data = raw_data[coin['name']][settings['base']]
          coin_display_data = display_data[coin['name']][settings['base']]
          past_price = coin['amount'] * coin['price']
          curr_price = coin['amount'] * coin_data['PRICE']
          to_symbol = coin_display_data['TOSYMBOL']
          change = curr_price - past_price
          arrow = pick_arrow(change)
          total_buy +=  past_price
          total += curr_price

          coin_details = [
            { value: add_color(coin['name'], :yellow), alignment: :left },
            coin['amount'],
            "#{to_symbol} #{coin['price'].round(2)}",
            "#{to_symbol} #{past_price.round(2)}",
            add_color("#{to_symbol} #{coin_data['PRICE'].round(2)}", pick_color(change)),
            add_color("#{to_symbol} #{curr_price.round(2)}", pick_color(change)),
            add_color("#{arrow} #{to_symbol} #{(curr_price - past_price).round(2)}",
                      pick_color(change)),
            add_color("#{arrow} #{percent_change(past_price, curr_price).round(2)}%",
                      pick_color(change))
          ]
          table << coin_details
        end

        total_change = percent_change(total_buy, total)
        arrow = pick_arrow(total_change)

        table << [
          { value: add_color('ALL', :cyan), alignment: :left}, '-', '-',
          "#{to_symbol} #{total_buy.round(2)}", '-',
          add_color("#{to_symbol} #{total.round(2)}", pick_color(total_change)),
          add_color("#{arrow} #{to_symbol} #{(total - total_buy).round(2)}",
                    pick_color(total_change)),
          add_color("#{arrow} #{total_change.round(2)}%", pick_color(total_change))
        ]

        table
      end
    end # Holdings
  end # Commands
end # Coinpare
