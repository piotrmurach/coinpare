if ENV['COVERAGE'] || ENV['TRAVIS']
  require 'simplecov'

  SimpleCov.start do
    command_name 'spec'
    add_filter 'spec'
  end
end
require 'bundler/setup'
require 'coinpare'
require 'open3'
require 'webmock/rspec'
require 'timecop'

ENV['THOR_COLUMNS'] = '80'
ENV['TTY_TEST'] = 'true'

puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
puts "LC_ALL: #{ENV['LC_ALL']}"
puts "LC_CTYPE: #{ENV['LC_CTYPE']}"
puts "LANG: #{ENV['LANG']}"
puts "△"
puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

module TestHelpers
  module Paths
    def gem_root
      File.expand_path("#{File.dirname(__FILE__)}/..")
    end

    def dir_path(*args)
      path = File.join(gem_root, *args)
      FileUtils.mkdir_p(path) unless File.exist?(path)
      File.realpath(path)
    end

    def tmp_path(*args)
      File.join(dir_path('tmp'), *args)
    end

    def fixtures_path(*args)
      File.join(dir_path('spec/fixtures'), *args)
    end

    def within_dir(target, &block)
      ::Dir.chdir(target, &block)
    end
  end

  module Silent
    def silent_run(*args)
      out = Tempfile.new('coinpare-cmd')
      result = system(*args, out: out.path)
      return if result
      out.rewind
      fail "#{args.join} failed:\n#{out.read}"
    end
  end
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.include(TestHelpers::Paths)
  config.include(TestHelpers::Silent)
  config.after(:example, type: :cli) do
    FileUtils.rm_rf(tmp_path)
  end
  config.disable_monkey_patching!
end
