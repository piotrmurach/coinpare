# frozen_string_literal: true

module Coinpare
  class Command
    SYMBOLS = {
      down_arrow: '▾',
      up_arrow: '▲'
    }.freeze

    # Main configuration
    # @api public
    def config
      @config ||= begin
        config = TTY::Config.new
        config.filename = 'coinpare'
        config.extname = '.toml'
        config.append_path Dir.pwd
        config.append_path Dir.home
        config
      end
    end

    # Time for when the data was fetched
    # @api public
    def timestamp
      "#{Time.now.strftime("%d %B %Y")} at #{Time.now.strftime("%I:%M:%S %p %Z")}"
    end

    # The exchange, currency & time banner
    # @api public
    def banner(settings)
      "\n#{add_color('Exchange', :yellow)} #{settings['exchange']}  " \
      "#{add_color('Currency', :yellow)} #{settings['base']}  " \
      "#{add_color('Time', :yellow)} #{timestamp}\n\n"
    end

    # Provide arrow for marking value growth or decline
    # @api public
    def pick_arrow(growing)
      growing ? SYMBOLS[:up_arrow] : SYMBOLS[:down_arrow]
    end

    def add_color(str, color)
      @options["no-color"] ? str : @pastel.decorate(str, color)
    end

    def pick_color(growing)
      growing ? :green : :red
    end

    def percent_change(before, after)
      (after - before) / before.to_f * 100
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
      require 'tty-cursor'
      TTY::Cursor
    end

    # Open a file or text in the user's preferred editor
    #
    # @see http://www.rubydoc.info/gems/tty-editor
    #
    # @api public
    def editor
      require 'tty-editor'
      TTY::Editor
    end

    # File manipulation utility methods
    #
    # @see http://www.rubydoc.info/gems/tty-file
    #
    # @api public
    def generator
      require 'tty-file'
      TTY::File
    end

    # Get terminal screen properties
    #
    # @see http://www.rubydoc.info/gems/tty-screen
    #
    # @api public
    def screen
      require 'tty-screen'
      TTY::Screen
    end

    # The unix which utility
    #
    # @see http://www.rubydoc.info/gems/tty-which
    #
    # @api public
    def which(*args)
      require 'tty-which'
      TTY::Which.which(*args)
    end

    # Check if executable exists
    #
    # @see http://www.rubydoc.info/gems/tty-which
    #
    # @api public
    def exec_exist?(*args)
      require 'tty-which'
      TTY::Which.exist?(*args)
    end
  end # Command
end # Coinpare
