RSpec.describe "`coinpare markets` command", type: :cli do
  it "executes `markets --help` command successfully" do
    output = `coinpare markets --help --no-color`
    expect(output).to eq <<-OUT
   ____           _                                       
  / ___|   ___   (_)  _ __    _ __     __ _   _ __    ___ 
 | |      / _ \\  | | | '_ \\  | '_ \\   / _` | | '__|  / _ \\
 | |___  | (_) | | | | | | | | |_) | | (_| | | |    |  __/
  \\____|  \\___/  |_| |_| |_| | .__/   \\__,_| |_|     \\___|
                             |_|                          
Usage:
  coinpare markets [NAME]

Options:
  -b, [--base=currency]      # The currency symbol to convert into
                             # Default: USD
  -c, [--columns=0 1 2]      # Specify columns to display
  -h, [--help], [--no-help]  # Display usage information
  -t, [--top=N]              # The number of top exchanges by total volume in 24 hours
                             # Default: 10
  -w, [--watch=n]            # Automatically refresh data every n seconds, default 5 sec
      [--no-color]           # Disable colorization in output

Description:
  Get top markets by volume for a currency pair.

  By default 10 top markets by their total volume across all markets in the last 
  24 hours.

  Example:

  > $ coinpare markets BTC --base USD

  Example:

  > $ coinpare markets ETH -b BTC
    OUT
  end
end
