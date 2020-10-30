# frozen_string_literal: true

module Coinpare
  class Command
    SYMBOLS = {
      down_arrow: "▼",
      up_arrow: "▲"
    }.freeze

    # The default interval for auto updating data
    DEFAULT_INTERVAL = 5

    trap("SIGINT") { exit }

    # Main configuration
    # @api public
    def config
      @config ||= begin
        config = TTY::Config.new
        config.filename = "coinpare"
        config.extname = ".toml"
        config.append_path Dir.pwd
        config.append_path Dir.home
        config
      end
    end

    # Time for when the data was fetched
    # @api public
    def timestamp
      "#{Time.now.strftime('%d %B %Y')} at #{Time.now.strftime('%I:%M:%S %p %Z')}"
    end

    # The exchange, currency & time banner
    # @api public
    def banner(settings)
      "\n#{add_color('Exchange', :yellow)} #{settings['exchange']}  " \
      "#{add_color('Currency', :yellow)} #{settings['base'].upcase}  " \
      "#{add_color('Time', :yellow)} #{timestamp}\n\n"
    end

    # Provide arrow for marking value growth or decline
    # @api public
    def pick_arrow(change)
      return if change.zero?

      change > 0 ? SYMBOLS[:up_arrow] : SYMBOLS[:down_arrow]
    end

    def add_color(str, color)
      @options["no-color"] || color == :none ? str : @pastel.decorate(str, color)
    end

    def pick_color(change)
      return :none if change.zero?

      change > 0 ? :green : :red
    end

    def percent(value)
      (value * 100).round(2)
    end

    def percent_change(before, after)
      (after - before) / before.to_f * 100
    end

    def shorten_currency(value)
      if value > 10**9
        "#{(value / 10**9).to_f.round(2)} B"
      elsif value > 10**6
        "#{(value / 10**6).to_f.round(2)} M"
      else
        value
      end
    end

    def precision(value, decimals = 2)
      part = value.to_s.split(".")[1]
      return 0 if part.nil?

      value.between?(0, 1) ? (part.index(/[^0]/) + decimals) : decimals
    end

    def round_to(value, prec = nil)
      prec = precision(value) if prec.nil?
      format("%.#{prec}f", value)
    end

    def number_to_currency(value)
      whole, part = value.to_s.split(".")
      part = "." + part unless part.nil?
      "#{whole.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')}#{part}"
    end

    # Execute this command
    #
    # @api public
    def execute(*)
      raise(
        NotImplementedError,
        "#{self.class}##{__method__} must be implemented"
      )
    end

    # The cursor movement
    #
    # @see http://www.rubydoc.info/gems/tty-cursor
    #
    # @api public
    def cursor
      require "tty-cursor"
      TTY::Cursor
    end

    # Open a file or text in the user's preferred editor
    #
    # @see http://www.rubydoc.info/gems/tty-editor
    #
    # @api public
    def editor
      require "tty-editor"
      TTY::Editor
    end

    # Get terminal screen properties
    #
    # @see http://www.rubydoc.info/gems/tty-screen
    #
    # @api public
    def screen
      require "tty-screen"
      TTY::Screen
    end
  end # Command
end # Coinpare
