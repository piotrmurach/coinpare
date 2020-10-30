# frozen_string_literal: true

require "net/http"
require "json"

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
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 5
      http.use_ssl = uri.scheme == "https"
      response = http.start { |req| req.get(uri.request_uri) }
      case response
      when Net::HTTPSuccess
        handle_response(JSON.parse(response.body))
      else
        response.value
      end
    rescue Net::ReadTimeout
    end
    module_function :fetch_json

    def fetch_daily_hist(from_symbol, to_symbol, options)
      url = ["#{API_URL}histoday"]
      url << "?fsym=#{from_symbol}&tsym=#{to_symbol}"
      url << "&limit=#{options['top']}" if options["top"]
      url << "&aggregate=7"

      fetch_json(url.join)
    end

    def fetch_top_coins_by_volume(to_symbol, options)
      url = ["#{API_URL}top/totalvol"]
      url << "?tsym=#{to_symbol}"
      url << "&limit=#{options['top']}&page=0" if options["top"]

      fetch_json(url.join)
    end
    module_function :fetch_top_coins_by_volume

    def fetch_prices(from_symbols, to_symbols, options)
      url = ["#{API_URL}pricemultifull"]
      url << "?fsyms=#{from_symbols}&tsyms=#{to_symbols}"
      url << "&e=#{options['exchange']}" if options["exchange"]
      url << "&tryConversion=true"

      fetch_json(url.join)
    end
    module_function :fetch_prices

    def fetch_top_exchanges_by_pair(from_symbol, to_symbol, options)
      url = ["#{API_URL}top/exchanges/full"]
      url << "?fsym=#{from_symbol}&tsym=#{to_symbol}"
      url << "&limit=#{options['top']}&page=0" if options["top"]

      fetch_json(url.join)
    end
    module_function :fetch_top_exchanges_by_pair
  end # Fetcher
end # Coinpare
