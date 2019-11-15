#
# Parse config from command-line arguments
#
class TeslaCam::CLI::Config < ::TeslaCam::Config
  def initialize(app, args)
    raise "missing command-line arguments" unless args.size > 4
    @output = args.shift
    @inputs = args
    @size = ::TeslaCam::Size.new(320, 240)
    @font_size = 16
  end
end
