require 'coinpare/commands/holdings'

RSpec.describe Coinpare::Commands::Holdings, type: :cli do
  before(:each) do
    time = Time.utc(2018, 4, 1, 12, 30, 54)
    Timecop.freeze(time)
    allow(TTY::Screen).to receive(:width).and_return(200)
  end

  it "creates coinpare.toml file with settings and holdings" do
    output = StringIO.new
    input = StringIO.new
    options = {"base"=>"USD", "exchange"=>"CCCAGG", "no-color"=>true}
    prices_path = fixtures_path('pricemultifull_top10.json')

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "BTC",
                    "tsyms" => "USD",
                    "e" => "CCCAGG",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)

    input << "\n\nY\nbtc\n1\n11500\nn\n"# Y\neth\n4\n600\nn\n"
    input.rewind

    command = Coinpare::Commands::Holdings.new(options)

    command.config.location_paths.clear
    command.config.append_path(tmp_path)

    command.execute(input: input, output: output)

    expected_output = <<-OUT
Currently you have no investments setup
Let's change that and setup your altfolio!

[c] What base currency to convert holdings to? (USD) \e[2K\e[1G[c] What base currency to convert holdings to? (USD) 
\e[1A\e[2K\e[1G[c] What base currency to convert holdings to? USD
[c] What exchange would you like to use? (CCCAGG) \e[2K\e[1G[c] What exchange would you like to use? (CCCAGG) 
\e[1A\e[2K\e[1G[c] What exchange would you like to use? CCCAGG
[c] Do you want to add coin to your altfolio? (Y/n) \e[2K\e[1G[c] Do you want to add coin to your altfolio? (Y/n) Y\e[2K\e[1G[c] Do you want to add coin to your altfolio? (Y/n) Y
\e[1A\e[2K\e[1G[c] Do you want to add coin to your altfolio? Yes
[c] What coin do you own? (BTC) \e[2K\e[1G[c] What coin do you own? (BTC) b\e[2K\e[1G[c] What coin do you own? (BTC) bt\e[2K\e[1G[c] What coin do you own? (BTC) btc\e[2K\e[1G[c] What coin do you own? (BTC) btc
\e[1A\e[2K\e[1G[c] What coin do you own? btc
[c] What amount? \e[2K\e[1G[c] What amount? 1\e[2K\e[1G[c] What amount? 1
\e[1A\e[2K\e[1G[c] What amount? 1
[c] At what price per coin? \e[2K\e[1G[c] At what price per coin? 1\e[2K\e[1G[c] At what price per coin? 11\e[2K\e[1G[c] At what price per coin? 115\e[2K\e[1G[c] At what price per coin? 1150\e[2K\e[1G[c] At what price per coin? 11500\e[2K\e[1G[c] At what price per coin? 11500
\e[1A\e[2K\e[1G[c] At what price per coin? 11500
[c] Do you want to add coin to your altfolio? (Y/n) \e[2K\e[1G[c] Do you want to add coin to your altfolio? (Y/n) n\e[2K\e[1G[c] Do you want to add coin to your altfolio? (Y/n) n
\e[1A\e[2K\e[1G[c] Do you want to add coin to your altfolio? no

Exchange CCCAGG  Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────┬────────┬───────────┬─────────────┬────────────┬──────────────────┬──────────────┬───────────┐
│ Coin │ Amount │     Price │ Total Price │ Cur. Price │ Total Cur. Price │       Change │   Change% │
├──────┼────────┼───────────┼─────────────┼────────────┼──────────────────┼──────────────┼───────────┤
│ BTC  │    1.0 │ $ 11500.0 │   $ 11500.0 │  $ 7002.45 │        $ 7002.45 │ ▾ $ -4497.55 │ ▾ -39.11% │
│ ALL  │      - │         - │   $ 11500.0 │          - │        $ 7002.45 │ ▾ $ -4497.55 │ ▾ -39.11% │
└──────┴────────┴───────────┴─────────────┴────────────┴──────────────────┴──────────────┴───────────┘
    OUT
    expect(output.string).to eq(expected_output)
  end

  it "reads holdings and settings from coinpare.toml file" do
    output = StringIO.new
    options = {"base"=>"USD", "exchange"=>"CCCAGG", "no-color"=>true}
    prices_path = fixtures_path('pricemultifull_top10.json')
    config_path = fixtures_path('coinpare.toml')

    ::FileUtils.cp(config_path, tmp_path)

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "BTC,ETH,TRX",
                    "tsyms" => "USD",
                    "e" => "CCCAGG",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)

    command = Coinpare::Commands::Holdings.new(options)

    command.config.location_paths.clear
    command.config.prepend_path(tmp_path)

    command.execute(output: output)

    expected_output = <<-OUT

Exchange CCCAGG  Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────┬────────┬──────────┬─────────────┬────────────┬──────────────────┬──────────────┬───────────┐
│ Coin │ Amount │    Price │ Total Price │ Cur. Price │ Total Cur. Price │       Change │   Change% │
├──────┼────────┼──────────┼─────────────┼────────────┼──────────────────┼──────────────┼───────────┤
│ BTC  │   1.25 │ $ 8000.0 │   $ 10000.0 │  $ 7002.45 │        $ 8753.06 │ ▲ $ -1246.94 │ ▲ -12.47% │
│ ETH  │    4.0 │  $ 600.0 │    $ 2400.0 │   $ 381.86 │        $ 1527.44 │  ▲ $ -872.56 │ ▲ -36.36% │
│ TRX  │ 2000.0 │   $ 0.02 │      $ 40.0 │     $ 0.03 │          $ 68.44 │    ▲ $ 28.44 │   ▲ 71.1% │
│ ALL  │      - │        - │   $ 12440.0 │          - │       $ 10348.94 │ ▾ $ -2091.06 │ ▾ -16.81% │
└──────┴────────┴──────────┴─────────────┴────────────┴──────────────────┴──────────────┴───────────┘
    OUT

    expect(output.string).to eq(expected_output)
  end

  it "displays advice when no portfolio configuration can be edited" do
    output = StringIO.new
    options = {"edit" => true, "base"=>"USD", "exchange"=>"CCCAGG", "no-color"=>true}

    command = Coinpare::Commands::Holdings.new(options)
    command.config.location_paths.clear

    command.execute(output: output)

    expected_output = <<-OUT
Sorry, no holdings configuration found.
Run "$ coinpare holdings" to setup new altfolio.
    OUT

    expect(output.string).to eq(expected_output)
  end
end
