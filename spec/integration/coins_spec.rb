require 'tty-screen'

RSpec.describe "`coinpare coins` command", type: :cli do
  before(:each) do
    allow(TTY::Screen).to receive(:width).and_return(200)
  end

  it "displays usage info" do
    output = <<-OUT
Usage:
  coinpare coins NAMES...

Options:
  -b, [--base=currency]      # The currency symbol to convert into
                             # Default: USD
  -c, [--columns=0 1 2]      # Specify columns to display
  -e, [--exchange=name]      # Name of exchange
                             # Default: CCCAGG
  -h, [--help], [--no-help]  # Display usage information
  -t, [--top=N]              # The number of top coins by total volume accross all markets in 24 hours
                             # Default: 10
      [--track=BTC TRX LTC]  # Save coins that you wish to track automatically
      [--no-color]           # Disable colorization in output

Description:
  Get all the current trading info (price, vol, open, high, low etc) of any list 
  of cryptocurrencies in any other currency that you need.

  By default 10 top coins by their total volume across all markets in the last 
  24 hours.

  Example:

  > $ coinpare coins BTC ETH --base USD

  Example:

  > $ coinpare coins BTC ETH --exchange coinbase
    OUT
    command = "coinpare coins --help"
    out, err, status = Open3.capture3(command)

    expect(out).to eq(output)
    expect(err).to eq('')
    expect(status.exitstatus).to eq(0)
  end
end
