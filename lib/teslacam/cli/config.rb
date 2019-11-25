require 'optparse'

#
# Parse config from command-line arguments
#
class TeslaCam::CLI::Config < ::TeslaCam::Config
  def initialize(app, args)
    # initialize defaults
    super()

    @inputs = OptionParser.new do |o|
      o.banner = "Usage: #{app} [options] <videos>"
      o.separator ''

      o.separator 'Options:'
      o.on('-o', '--output [FILE]', String, 'Output file.') do |val|
        @output = val
      end

      o.on('-s', '--size [SIZE]', String, 'Output size (WxH).') do |val|
        md = val.match(/^(?<w>\d+)x(?<h>\d+)$/)
        raise "invalid size: #{val}" unless md
        @size = ::TeslaCam::Size.new(md[:w].to_i / 2, md[:h].to_i / 2)
      end

      o.on('--font-size [SIZE]', Integer, 'Font size.') do |val|
        raise "invalid font size: #{val}" if val < 1
        @font_size = val
      end

      o.on('--bg-color [COLOR]', Integer, 'Background color.') do |val|
        raise "invalid font size: #{val}" if val < 1
        @missing_color = val
      end

      o.on('-t', '--title [TITLE]', String, 'Video title.') do |val|
        @title = val
      end

      o.on('-p', '--preset [name]', String, 'Use preset.') do |val|
        p = ::TeslaCam::CLI::Presets.get(val)
        @size = ::TeslaCam::Size.new(p[:size][0] / 2, p[:size][1] / 2)
        @font_size = p[:font_size]
      end

      o.on('-q', '--quiet', 'Silence ffmpeg output.') do
        @quiet = true
      end

      o.on_tail('-h', '--help', 'Show help.') do
        puts o
        exit 0
      end
    end.parse(args)

    raise "missing input videos" unless @inputs.size > 0
    raise "missing output" unless @output
  end
end
