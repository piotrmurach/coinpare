# frozen_string_literal: true

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

    input << "\n\nY\nbtc\n1\n11500\nn\n"
    input.rewind

    command = Coinpare::Commands::Holdings.new(options)

    command.config.location_paths.clear
    command.config.append_path(tmp_path)

    command.execute(input: input, output: output)

    expected_output = <<-OUT
Exchange CCCAGG  Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────┬────────┬─────────────┬─────────────┬────────────┬──────────────────┬───────────────┬───────────┐
│ Coin │ Amount │       Price │ Total Price │ Cur. Price │ Total Cur. Price │        Change │   Change% │
├──────┼────────┼─────────────┼─────────────┼────────────┼──────────────────┼───────────────┼───────────┤
│ BTC  │    1.0 │ $ 11,500.00 │ $ 11,500.00 │ $ 7,002.45 │       $ 7,002.45 │ ▼ $ -4,497.55 │ ▼ -39.11% │
│ ALL  │      - │           - │ $ 11,500.00 │          - │       $ 7,002.45 │ ▼ $ -4,497.55 │ ▼ -39.11% │
└──────┴────────┴─────────────┴─────────────┴────────────┴──────────────────┴───────────────┴───────────┘
    OUT
    expect(output.string).to include(expected_output)
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

┌──────┬────────┬────────────┬─────────────┬────────────┬──────────────────┬───────────────┬───────────┐
│ Coin │ Amount │      Price │ Total Price │ Cur. Price │ Total Cur. Price │        Change │   Change% │
├──────┼────────┼────────────┼─────────────┼────────────┼──────────────────┼───────────────┼───────────┤
│ BTC  │   1.25 │ $ 8,000.00 │ $ 10,000.00 │ $ 7,002.45 │       $ 8,753.06 │ ▼ $ -1,246.94 │ ▼ -12.47% │
│ ETH  │    4.0 │   $ 600.00 │  $ 2,400.00 │   $ 381.86 │       $ 1,527.44 │   ▼ $ -872.56 │ ▼ -36.36% │
│ TRX  │ 2000.0 │    $ 0.020 │     $ 40.00 │    $ 0.034 │          $ 68.44 │     ▲ $ 28.44 │  ▲ 71.10% │
│ ALL  │      - │          - │ $ 12,440.00 │          - │      $ 10,348.94 │ ▼ $ -2,091.06 │ ▼ -16.81% │
└──────┴────────┴────────────┴─────────────┴────────────┴──────────────────┴───────────────┴───────────┘
    OUT

    expect(output.string).to eq(expected_output)
  end

  it "adds a new holding" do
    input = StringIO.new
    output = StringIO.new
    options = {"base"=>"USD", "exchange"=>"CCCAGG", "no-color"=>true, "add" => true}
    prices_path = fixtures_path('pricemultifull_top10.json')
    config_path = fixtures_path('coinpare.toml')

    ::FileUtils.cp(config_path, tmp_path)

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "BTC,ETH,TRX,LTC",
                    "tsyms" => "USD",
                    "e" => "CCCAGG",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)

    input << "LTC\n4\n120\n"
    input.rewind

    command = Coinpare::Commands::Holdings.new(options)

    command.config.location_paths.clear
    command.config.prepend_path(tmp_path)

    command.execute(input: input, output: output)

    config = TTY::Config.new
    config.read(tmp_path('coinpare.toml'))

    expect(config.fetch(:holdings)).to include({"amount"=>4.0, "name" => "LTC", "price" => 120.0})

    expected_output = <<-OUT
Exchange CCCAGG  Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────┬────────┬────────────┬─────────────┬────────────┬──────────────────┬───────────────┬───────────┐
│ Coin │ Amount │      Price │ Total Price │ Cur. Price │ Total Cur. Price │        Change │   Change% │
├──────┼────────┼────────────┼─────────────┼────────────┼──────────────────┼───────────────┼───────────┤
│ BTC  │   1.25 │ $ 8,000.00 │ $ 10,000.00 │ $ 7,002.45 │       $ 8,753.06 │ ▼ $ -1,246.94 │ ▼ -12.47% │
│ ETH  │    4.0 │   $ 600.00 │  $ 2,400.00 │   $ 381.86 │       $ 1,527.44 │   ▼ $ -872.56 │ ▼ -36.36% │
│ TRX  │ 2000.0 │    $ 0.020 │     $ 40.00 │    $ 0.034 │          $ 68.44 │     ▲ $ 28.44 │  ▲ 71.10% │
│ LTC  │    4.0 │   $ 120.00 │    $ 480.00 │   $ 118.10 │         $ 472.40 │     ▼ $ -7.60 │  ▼ -1.58% │
│ ALL  │      - │          - │ $ 12,920.00 │          - │      $ 10,821.34 │ ▼ $ -2,098.66 │ ▼ -16.24% │
└──────┴────────┴────────────┴─────────────┴────────────┴──────────────────┴───────────────┴───────────┘
    OUT

    expect(output.string).to include(expected_output)
  end

  it "removes selected holdings" do
    input = StringIO.new
    output = StringIO.new
    options = {"base"=>"USD", "exchange"=>"CCCAGG", "no-color"=>true, "remove" => true}
    prices_path = fixtures_path('pricemultifull_top10.json')
    config_path = fixtures_path('coinpare.toml')

    ::FileUtils.cp(config_path, tmp_path)

    stub_request(:get, "https://min-api.cryptocompare.com/data/pricemultifull")
      .with(query: {"fsyms" => "BTC",
                    "tsyms" => "USD",
                    "e" => "CCCAGG",
                    "tryConversion" => "true"})
      .to_return(body: File.new(prices_path), status: 200)

    input << "j" << " " << "j" << " " << "\r"
    input.rewind

    command = Coinpare::Commands::Holdings.new(options)

    command.config.location_paths.clear
    command.config.prepend_path(tmp_path)

    command.execute(input: input, output: output)

    config = TTY::Config.new
    config.read(tmp_path('coinpare.toml'))

    expect(config.fetch(:holdings)).to eq([{"amount"=>1.25, "name" => "BTC", "price" => 8000.0}])

    expected_output = <<-OUT
Exchange CCCAGG  Currency USD  Time 01 April 2018 at 12:30:54 PM UTC

┌──────┬────────┬────────────┬─────────────┬────────────┬──────────────────┬───────────────┬───────────┐
│ Coin │ Amount │      Price │ Total Price │ Cur. Price │ Total Cur. Price │        Change │   Change% │
├──────┼────────┼────────────┼─────────────┼────────────┼──────────────────┼───────────────┼───────────┤
│ BTC  │   1.25 │ $ 8,000.00 │ $ 10,000.00 │ $ 7,002.45 │       $ 8,753.06 │ ▼ $ -1,246.94 │ ▼ -12.47% │
│ ALL  │      - │          - │ $ 10,000.00 │          - │       $ 8,753.06 │ ▼ $ -1,246.94 │ ▼ -12.47% │
└──────┴────────┴────────────┴─────────────┴────────────┴──────────────────┴───────────────┴───────────┘
    OUT

    expect(output.string).to include(expected_output)
  end

  it "removes all holdings with select menu" do
    input = StringIO.new
    output = StringIO.new
    options = {"base"=>"USD", "exchange"=>"CCCAGG", "no-color"=>true, "remove" => true}
    config_path = fixtures_path('coinpare.toml')

    ::FileUtils.cp(config_path, tmp_path)

    input <<  " " << "j" << " " << "j" << " " <<  "\r"
    input.rewind

    command = Coinpare::Commands::Holdings.new(options)

    command.config.location_paths.clear
    command.config.prepend_path(tmp_path)

    expect {
      command.execute(input: input, output: output)
    }.to raise_error(SystemExit)

    config = TTY::Config.new
    config.read(tmp_path('coinpare.toml'))

    expect(config.fetch(:holdings)).to eq(nil)
  end

  it "clears all holdings" do
    input = StringIO.new
    output = StringIO.new
    options = {"base"=>"USD", "exchange"=>"CCCAGG", "no-color"=>true, "clear" => true}
    config_path = fixtures_path('coinpare.toml')

    ::FileUtils.cp(config_path, tmp_path)

    command = Coinpare::Commands::Holdings.new(options)

    command.config.location_paths.clear
    command.config.prepend_path(tmp_path)

    expect {
      command.execute(input: input, output: output)
    }.to raise_error(SystemExit)

    config = TTY::Config.new
    config.read(tmp_path('coinpare.toml'))

    expect(config.fetch(:holdings)).to eq(nil)
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

  it "displays holdings in pie chart" do
    output = StringIO.new
    options = {
      "pie" => 2,
      "radius" => 5,
      "base"=>"USD",
      "exchange"=>"CCCAGG",
      "no-color"=>true
    }
    config_path = fixtures_path('coinpare.toml')
    ::FileUtils.cp(config_path, tmp_path)
    prices_path = fixtures_path('pricemultifull_top10.json')

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

┌─────────────────────────────────────┬─────────────────────────────────────────────────┐
│      Total Price ($ 12,440.00)      │  Total Current Price ($10,348.94) ▼ $-2,091.06  │
├─────────────────────────────────────┼─────────────────────────────────────────────────┤
│     •••     • BTC $10,000.00 (80%)  │     •••     • BTC $8,753.06 (85%)               │
│   •••••••                           │   •••••••                                       │
│  •••••••••  • ETH $2,400.00 (19%)   │  •••••••••  • ETH $1,527.44 (15%)               │
│   •••••••                           │   •••••••                                       │
│     •••     • TRX $40.00 (0%)       │     •••     • TRX $68.44 (1%)                   │
└─────────────────────────────────────┴─────────────────────────────────────────────────┘
    OUT
    expect(output.string).to include(expected_output)
  end
end
