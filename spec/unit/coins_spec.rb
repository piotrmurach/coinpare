require 'coinpare/commands/coins'

RSpec.describe Coinpare::Commands::Coins, 'coins command' do
  before(:each) do
    time = Time.utc(2018, 4, 1, 12, 30, 54)
    Timecop.freeze(time)
    allow(TTY::Screen).to receive(:width).and_return(200)
  end

  after(:each) { Timecop.return }

  it "prints two coins ETH & DASH using USD as base currency" do
    output = StringIO.new
    prices_path = fixtures_path('pricemultifull.json')
    options = {"base"=>"USD", "exchange"=>"CCCAGG", "limit"=>10, "no-color"=>true}
    names = ['ETH', 'DASH']

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "ETH,DASH",
                    "tsyms" => "USD",
                    "e" => "CCCAGG",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)

    command = Coinpare::Commands::Coins.new(names, options)

    command.execute(output: output)

    expected_output = <<-OUT

Exchange CCCAGG  Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────┬──────────┬───────────┬───────────┬──────────┬──────────┬──────────┬─────────────────┬────────────────┬──────────────┐
│ Coin │    Price │  Chg. 24H │ Chg.% 24H │ Open 24H │ High 24H │  Low 24H │ Direct Vol. 24H │ Total Vol. 24H │   Market Cap │
├──────┼──────────┼───────────┼───────────┼──────────┼──────────┼──────────┼─────────────────┼────────────────┼──────────────┤
│ ETH  │ $ 385.46 │ ▲ $ 20.77 │   ▲ 5.70% │ $ 364.69 │ $ 394.52 │ $ 360.69 │ $ 202,740,667.0 │     $ 587.52 M │    $ 37.99 B │
│ DASH │ $ 303.32 │ ▲ $ 10.15 │   ▲ 3.46% │ $ 293.17 │ $ 316.31 │ $ 287.23 │   $ 6,944,036.6 │      $ 65.32 M │ $ 2,421.87 M │
└──────┴──────────┴───────────┴───────────┴──────────┴──────────┴──────────┴─────────────────┴────────────────┴──────────────┘
    OUT
    expect(output.string).to eq(expected_output)
  end

  it "prints two coins BTC, ETH using GBP as base currency" do
    output = StringIO.new
    prices_path = fixtures_path('pricemultifull_gbp.json')
    options = {"base"=>"GBP", "exchange"=>"CCCAGG", "limit"=>10, "no-color"=>true}
    names = ['BTC', 'ETH']

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "BTC,ETH",
                    "tsyms" => "GBP",
                    "e" => "CCCAGG",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)

    command = Coinpare::Commands::Coins.new(names, options)

    command.execute(output: output)

    expected_output = <<-OUT

Exchange CCCAGG  Currency GBP  Time 01 April 2018 at 12:30:54 PM UTC

┌──────┬────────────┬───────────┬───────────┬────────────┬────────────┬────────────┬─────────────────┬────────────────┬────────────┐
│ Coin │      Price │  Chg. 24H │ Chg.% 24H │   Open 24H │   High 24H │    Low 24H │ Direct Vol. 24H │ Total Vol. 24H │ Market Cap │
├──────┼────────────┼───────────┼───────────┼────────────┼────────────┼────────────┼─────────────────┼────────────────┼────────────┤
│ BTC  │ £ 4,975.98 │ ▲ £ 68.26 │   ▲ 1.39% │ £ 4,907.72 │ £ 5,077.22 │ £ 4,835.81 │   £ 3,131,434.5 │   £ 2,367.80 M │  £ 84.36 B │
│ ETH  │   £ 273.88 │ ▾ £ -3.18 │  ▾ -1.15% │   £ 277.06 │   £ 278.46 │   £ 271.99 │     £ 329,017.7 │     £ 358.00 M │  £ 27.00 B │
└──────┴────────────┴───────────┴───────────┴────────────┴────────────┴────────────┴─────────────────┴────────────────┴────────────┘
    OUT
    expect(output.string).to eq(expected_output)
  end

  it "prints three coins BTC, ETH, LTC using coinbase as exchange" do
    output = StringIO.new
    prices_path = fixtures_path('pricemultifull_coinbase.json')
    options = {"base"=>"USD", "exchange"=>"coinbase", "limit"=>10, "no-color"=>true}
    names = ['BTC', 'ETH', 'LTC']

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "BTC,ETH,LTC",
                    "tsyms" => "USD",
                    "e" => "coinbase",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)

    command = Coinpare::Commands::Coins.new(names, options)

    command.execute(output: output)

    expected_output = <<-OUT

Exchange coinbase  Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────┬────────────┬────────────┬───────────┬────────────┬────────────┬────────────┬─────────────────┬────────────────┬──────────────┐
│ Coin │      Price │   Chg. 24H │ Chg.% 24H │   Open 24H │   High 24H │    Low 24H │ Direct Vol. 24H │ Total Vol. 24H │   Market Cap │
├──────┼────────────┼────────────┼───────────┼────────────┼────────────┼────────────┼─────────────────┼────────────────┼──────────────┤
│ BTC  │ $ 7,000.65 │ ▲ $ 154.46 │   ▲ 2.26% │ $ 6,846.19 │ $ 7,148.55 │ $ 6,781.06 │ $ 731,839,077.3 │   $ 3,335.82 M │   $ 118.69 B │
│ ETH  │   $ 384.55 │   ▲ $ 4.75 │   ▲ 1.25% │   $ 379.80 │   $ 394.58 │   $ 375.59 │ $ 155,120,697.0 │     $ 503.95 M │    $ 37.91 B │
│ LTC  │   $ 118.73 │   ▲ $ 4.02 │   ▲ 3.50% │   $ 114.71 │   $ 121.91 │   $ 113.98 │  $ 54,517,493.9 │     $ 174.03 M │ $ 6,637.76 M │
└──────┴────────────┴────────────┴───────────┴────────────┴────────────┴────────────┴─────────────────┴────────────────┴──────────────┘
    OUT
    expect(output.string).to eq(expected_output)
  end

  it "prints top 10 coins by volume when no coin symbols specified" do
    output = StringIO.new
    top_coins_path = fixtures_path('toptotalvol.json')
    prices_path = fixtures_path('pricemultifull_top10.json')
    names = %w(BTC ETH EOS TRX LTC BCH XRP HT ETC DASH)
    options = {"no-color"=>true, "base"=>"USD", "exchange"=>"CCCAGG", "top"=>10}

    stub_request(:get, "https://min-api.cryptocompare.com/data/top/totalvol")
      .with(query: {"tsym" => "USD", "limit" => "10", "page" => "0"})
      .to_return(body: File.new(top_coins_path))

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => names.join(','),
                    "tsyms" => "USD",
                    "e" => "CCCAGG",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)

    command = Coinpare::Commands::Coins.new(names, options)

    command.execute(output: output)

    expected_output = <<-OUT

Exchange CCCAGG  Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────┬────────────┬─────────────┬───────────┬────────────┬────────────┬────────────┬─────────────────┬────────────────┬──────────────┐
│ Coin │      Price │    Chg. 24H │ Chg.% 24H │   Open 24H │   High 24H │    Low 24H │ Direct Vol. 24H │ Total Vol. 24H │   Market Cap │
├──────┼────────────┼─────────────┼───────────┼────────────┼────────────┼────────────┼─────────────────┼────────────────┼──────────────┤
│ BTC  │ $ 7,002.45 │   ▲ $ 89.71 │   ▲ 1.30% │ $ 6,912.74 │ $ 7,148.55 │ $ 6,781.62 │ $ 686,392,903.0 │   $ 3,174.09 M │   $ 118.72 B │
│ ETH  │   $ 381.86 │   ▾ $ -0.62 │  ▾ -0.16% │   $ 382.48 │   $ 394.58 │   $ 375.59 │ $ 142,744,906.9 │     $ 481.55 M │    $ 37.64 B │
│ EOS  │     $ 5.72 │    ▲ $ 0.10 │   ▲ 1.78% │     $ 5.62 │     $ 5.90 │     $ 5.49 │  $ 26,704,666.6 │     $ 225.97 M │ $ 5,720.00 M │
│ TRX  │  $ 0.03422 │  ▲ $ 0.0014 │   ▲ 4.39% │  $ 0.03278 │  $ 0.03628 │  $ 0.03113 │   $ 1,618,472.2 │     $ 158.54 M │ $ 3,422.00 M │
│ LTC  │   $ 118.10 │    ▲ $ 2.74 │   ▲ 2.38% │   $ 115.36 │   $ 121.85 │   $ 114.01 │  $ 51,507,963.3 │     $ 166.66 M │ $ 6,602.65 M │
│ BCH  │   $ 669.65 │   ▲ $ 15.13 │   ▲ 2.31% │   $ 654.52 │   $ 690.01 │   $ 639.93 │  $ 20,948,592.9 │     $ 162.33 M │    $ 11.42 B │
│ XRP  │   $ 0.4863 │ ▾ $ -0.0025 │  ▾ -0.51% │   $ 0.4888 │   $ 0.5045 │   $ 0.4711 │  $ 25,835,480.4 │     $ 171.49 M │    $ 18.63 B │
│ HT   │     $ 1.71 │   ▲ $ 0.035 │   ▲ 2.07% │     $ 1.68 │     $ 1.74 │     $ 1.65 │             $ 0 │      $ 99.56 M │   $ 857.45 M │
│ ETC  │    $ 13.92 │   ▲ $ 0.080 │   ▲ 0.58% │    $ 13.84 │    $ 14.30 │    $ 13.48 │   $ 6,380,328.3 │      $ 71.06 M │ $ 1,404.78 M │
│ DASH │   $ 310.42 │   ▾ $ -0.87 │  ▾ -0.28% │   $ 311.29 │   $ 316.62 │   $ 289.26 │   $ 5,913,106.3 │      $ 65.26 M │ $ 2,478.70 M │
└──────┴────────────┴─────────────┴───────────┴────────────┴────────────┴────────────┴─────────────────┴────────────────┴──────────────┘
    OUT
    expect(output.string).to eq(expected_output)
  end
end
