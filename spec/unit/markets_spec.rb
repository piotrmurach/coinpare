# frozen_string_literal: true

require 'coinpare/commands/markets'

RSpec.describe Coinpare::Commands::Markets do
  before(:each) do
    time = Time.utc(2018, 4, 1, 12, 30, 54)
    Timecop.freeze(time)
    allow(TTY::Screen).to receive(:width).and_return(200)
  end

  it "prints top markets for BTC & USD" do
    output = StringIO.new
    prices_path = fixtures_path('pricemultifull_top10.json')
    exchanges_path = fixtures_path('exchangesfull_top10.json')
    options = {"base"=>"USD", "top"=>10, "no-color"=>true}

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "BTC",
                    "tsyms" => "USD",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)


    stub_request(:get, "https://min-api.cryptocompare.com/data/top/exchanges/full")
      .with(query: {"fsym" => "BTC",
                    "tsym" => "USD",
                    "limit" => "10", 
                    "page" => "0"})
      .to_return(body: File.new(exchanges_path), status: 200)

    command = Coinpare::Commands::Markets.new('BTC', options)

    command.execute(output: output)

    expected_output = <<-OUT

Coin BTC  Base Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────────┬────────────┬─────────────┬────────────┬────────────┬────────────┬────────────┬──────────────────┐
│ Market   │      Price │    Chg. 24H │  Chg.% 24H │   Open 24H │   High 24H │    Low 24H │  Direct Vol. 24H │
├──────────┼────────────┼─────────────┼────────────┼────────────┼────────────┼────────────┼──────────────────┤
│ Bitfinex │ $ 9,122.50 │ ▼ $ -138.40 │ ▼ -149.45% │ $ 9,260.90 │ $ 9,393.90 │ $ 9,047.10 │ $ 192,448,713.47 │
│ Bitstamp │ $ 9,116.09 │ ▼ $ -123.91 │ ▼ -134.10% │    $ 9,240 │    $ 9,393 │    $ 9,050 │ $ 100,336,858.18 │
│ Coinbase │    $ 9,120 │ ▼ $ -114.85 │ ▼ -124.37% │ $ 9,234.85 │ $ 9,386.31 │ $ 9,056.93 │  $ 60,991,360.82 │
│ HitBTC   │ $ 9,170.05 │ ▼ $ -102.69 │ ▼ -110.74% │ $ 9,272.74 │ $ 9,398.39 │    $ 9,100 │  $ 56,968,995.14 │
│ itBit    │ $ 9,118.09 │ ▼ $ -128.91 │ ▼ -139.41% │    $ 9,247 │ $ 9,391.97 │ $ 9,051.74 │  $ 39,133,536.25 │
└──────────┴────────────┴─────────────┴────────────┴────────────┴────────────┴────────────┴──────────────────┘
    OUT

    expect(output.string).to eq(expected_output)
  end

  it "prints base currency symbols" do
    output = StringIO.new
    prices_path = fixtures_path('pricemultifull_btc_ltc.json')
    exchanges_path = fixtures_path('exchangesfull_ltc_base.json')
    options = {"base"=>"LTC", "no-color"=>true}

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "BTC",
                    "tsyms" => "LTC",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)


    stub_request(:get, "https://min-api.cryptocompare.com/data/top/exchanges/full")
      .with(query: {"fsym" => "BTC", "tsym" => "LTC"})
      .to_return(body: File.new(exchanges_path), status: 200)

    command = Coinpare::Commands::Markets.new('BTC', options)

    command.execute(output: output)

    expected_output = <<-OUT

Coin BTC  Base Currency LTC  Time 01 April 2018 at 12:30:54 PM UTC

┌───────────────┬──────────┬───────────┬───────────┬──────────┬──────────┬──────────┬─────────────────┐
│ Market        │    Price │  Chg. 24H │ Chg.% 24H │ Open 24H │ High 24H │  Low 24H │ Direct Vol. 24H │
├───────────────┼──────────┼───────────┼───────────┼──────────┼──────────┼──────────┼─────────────────┤
│ LocalBitcoins │  Ł 61.23 │ ▼ Ł -0.16 │ ▼ -26.06% │  Ł 61.39 │  Ł 61.39 │  Ł 61.23 │          Ł 0.68 │
│ OKCoin        │  Ł 18.46 │       Ł 0 │        0% │  Ł 18.46 │  Ł 18.46 │  Ł 18.46 │             Ł 0 │
│ Kraken        │ Ł 0.0041 │       Ł 0 │        0% │ Ł 0.0041 │ Ł 0.0041 │ Ł 0.0041 │             Ł 0 │
│ CCEX          │ Ł 155.87 │       Ł 0 │        0% │ Ł 155.87 │ Ł 155.87 │ Ł 155.87 │             Ł 0 │
│ BitSquare     │  Ł 49.00 │       Ł 0 │        0% │  Ł 49.00 │  Ł 49.00 │  Ł 49.00 │             Ł 0 │
└───────────────┴──────────┴───────────┴───────────┴──────────┴──────────┴──────────┴─────────────────┘
    OUT

    expect(output.string).to eq(expected_output)
  end

  it "prints small precision currencies" do
    output = StringIO.new
    prices_path = fixtures_path('pricemultifull_top10.json')
    exchanges_path = fixtures_path('exchangesfull_trx.json')
    options = {"base"=>"USD", "no-color"=>true}

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "TRX",
                    "tsyms" => "USD",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)


    stub_request(:get, "https://min-api.cryptocompare.com/data/top/exchanges/full")
      .with(query: {"fsym" => "TRX", "tsym" => "USD"})
      .to_return(body: File.new(exchanges_path), status: 200)

    command = Coinpare::Commands::Markets.new('TRX', options)

    command.execute(output: output)

    expected_output = <<-OUT

Coin TRX  Base Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────────┬─────────┬────────────┬────────────┬──────────┬──────────┬─────────┬─────────────────┐
│ Market   │   Price │   Chg. 24H │  Chg.% 24H │ Open 24H │ High 24H │ Low 24H │ Direct Vol. 24H │
├──────────┼─────────┼────────────┼────────────┼──────────┼──────────┼─────────┼─────────────────┤
│ Bitfinex │ $ 0.074 │ ▲ $ 0.0083 │ ▲ 1263.48% │  $ 0.066 │  $ 0.076 │ $ 0.065 │  $ 1,874,744.19 │
│ HitBTC   │ $ 0.075 │ ▲ $ 0.0087 │ ▲ 1313.71% │  $ 0.066 │  $ 0.076 │ $ 0.066 │  $ 1,007,006.56 │
│ Yobit    │ $ 0.078 │ ▲ $ 0.0092 │ ▲ 1347.84% │  $ 0.069 │  $ 0.079 │ $ 0.068 │     $ 44,741.07 │
│ BitFlip  │ $ 0.084 │  ▲ $ 0.010 │ ▲ 1351.35% │  $ 0.074 │  $ 0.084 │ $ 0.071 │        $ 922.52 │
└──────────┴─────────┴────────────┴────────────┴──────────┴──────────┴─────────┴─────────────────┘
    OUT

    expect(output.string).to eq(expected_output)
  end
end
