#
# Parse config from command-line arguments
#
class TeslaCam::CLI::Config < ::TeslaCam::Config
  def initialize(app, args)
    # initialize defaults
    super()

    # check number of command-line arguments
    raise "missing command-line arguments" unless args.size > 4

    # get config from command-line
    @output = args.shift
    @inputs = args
    @size = ::TeslaCam::Size.new(320, 240)
    @font_size = 16
  end
end
