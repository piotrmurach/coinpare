RSpec.describe "`coinpare holdings` command", type: :cli do
  it "executes `holdings --help` command successfully" do
    output = `coinpare holdings --help`
    expect(output).to eq <<-OUT
Usage:
  coinpare holdings

Options:
      [--add], [--no-add]        # Add a new coin without altering any existhing holdings
  -b, [--base=currency]          # The currency symbol to convert into
                                 # Default: USD
      [--edit=editor]            # Open the holdings configuration file for editing in EDITOR, or the default editor if not specified.
  -e, [--exchange=name]          # Name of exchange
                                 # Default: CCCAGG
  -h, [--help], [--no-help]      # Display usage information
      [--remove], [--no-remove]  # Remove the given coin(s) from holdings
      [--reset], [--no-reset]    # Remove all coins from your existing holdings
      [--no-color]               # Disable colorization in output

Description:
  Get the current trading prices and their change in value and percentage for 
  all your cryptocurrency investments.

  Example:

  > $ coinpare holdings

  Example

  > $ coinpare holdings --exchange coinbase --base USD
    OUT
  end
end
