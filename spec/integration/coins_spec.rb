# frozen_string_literal: true

RSpec.describe "`coinpare coins` command", type: :cli do
  it "displays usage info" do
    output = <<-OUT
   ____           _                                       
  / ___|   ___   (_)  _ __    _ __     __ _   _ __    ___ 
 | |      / _ \\  | | | '_ \\  | '_ \\   / _` | | '__|  / _ \\
 | |___  | (_) | | | | | | | | |_) | | (_| | | |    |  __/
  \\____|  \\___/  |_| |_| |_| | .__/   \\__,_| |_|     \\___|
                             |_|                          
Usage:
  coinpare coins NAMES...

Options:
  -b, [--base=CURRENCY]      # The currency symbol to convert into
                             # Default: USD
  -c, [--columns=0 1 2]      # Specify columns to display
  -e, [--exchange=name]      # Name of exchange
                             # Default: CCCAGG
  -h, [--help], [--no-help]  # Display usage information
  -t, [--top=N]              # The number of top coins by total volume accross all markets in 24 hours
                             # Default: 10
  -w, [--watch=N]            # Automatically refresh data every n seconds, default 5 sec
      [--no-color]           # Disable colorization in output

Description:
  Get all the current trading info (price, vol, open, high, low etc) of any list
  of cryptocurrencies in any other currency that you need.

  By default 10 top coins by their total volume across all markets in the last 24
  hours.

  Example:

  > $ coinpare coins BTC ETH --base USD

  Example:

  > $ coinpare coins BTC ETH --exchange coinbase
    OUT
    command = "coinpare coins --help --no-color"
    out, err, status = Open3.capture3(command)

    expect(out).to eq(output)
    expect(err).to eq("")
    expect(status.exitstatus).to eq(0)
  end
end
