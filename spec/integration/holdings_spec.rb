# frozen_string_literal: true

RSpec.describe "`coinpare holdings` command", type: :cli do
  it "executes `holdings --help` command successfully" do
    output = `coinpare holdings --help --no-color`
    expect(output).to eq <<-OUT
   ____           _                                       
  / ___|   ___   (_)  _ __    _ __     __ _   _ __    ___ 
 | |      / _ \\  | | | '_ \\  | '_ \\   / _` | | '__|  / _ \\
 | |___  | (_) | | | | | | | | |_) | | (_| | | |    |  __/
  \\____|  \\___/  |_| |_| |_| | .__/   \\__,_| |_|     \\___|
                             |_|                          
Usage:
  coinpare holdings

Options:
      [--add], [--no-add]        # Add a new coin without altering any existhing holdings
  -b, [--base=CURRENCY]          # The currency symbol to convert into
      [--clear], [--no-clear]    # Remove all coins from your existing holdings
      [--edit=editor]            # Open the holdings configuration file for editing in EDITOR, or the default editor if not specified.
  -e, [--exchange=NAME]          # Name of exchange
  -h, [--help], [--no-help]      # Display usage information
      [--remove], [--no-remove]  # Remove the given coin(s) from holdings
  -w, [--watch=N]                # Automatically refresh data every n seconds, default 5 sec
      [--no-color]               # Disable colorization in output

Description:
  Get the current trading prices and their change in value and percentage for all
  your cryptocurrency investments.

  Example:

  > $ coinpare holdings

  Example

  > $ coinpare holdings --exchange coinbase --base USD
    OUT
  end
end
