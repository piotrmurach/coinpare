# frozen_string_literal: true

require 'net/http'
require 'json'

module Coinpare
  # Handle all data fetching from remote api
  module Fetcher
    API_URL = "https://min-api.cryptocompare.com/data/"

    def handle_response(response)
      status = response["Response"]
      if status == "Error"
        puts response["Message"]
        exit
      end
      response
    end
    module_function :handle_response

    def fetch_json(url)
      response = Net::HTTP.get(URI.parse(url))
      handle_response(JSON.parse(response))
    end
    module_function :fetch_json

    def fetch_daily_hist(from_symbol, to_symbol, options)
      url = ["#{API_URL}histoday"]
      url << "?fsym=BTC&tsym=USD&limit=7&aggregate=7"

      fetch_json(url.join)
    end

    def fetch_top_coins_by_volume(to_symbol, options)
      url = ["#{API_URL}top/totalvol"]
      url << "?tsym=#{to_symbol}"
      url << "&limit=#{options['top']}&page=0" if options['top']

      fetch_json(url.join)
    end
    module_function :fetch_top_coins_by_volume

    def fetch_prices(from_symbols, to_symbols, options)
      url = ["#{API_URL}pricemultifull"]
      url << "?fsyms=#{from_symbols}&tsyms=#{to_symbols}"
      url << "&e=#{options['exchange']}" if options['exchange']
      url << "&tryConversion=true"

      fetch_json(url.join)
    end
    module_function :fetch_prices
  end
end
