require 'optparse'

#
# Parse config from command-line arguments
#
class TeslaCam::CLI::Config < ::TeslaCam::Config
  def initialize(app, args)
    # initialize defaults
    super()

    defaults = ::TeslaCam::Config::DEFAULTS
    @inputs = OptionParser.new do |o|
      o.banner = "Usage: #{app} [options] <input_videos>"
      o.separator ''

      o.separator 'Options:'
      o.on(
        '-o', '--output [FILE]', String,
        'Output file (required).'
      ) do |val|
        @output = val
      end

      o.on(
        '-s', '--size [SIZE]', String,
        'Output size (WxH).',
        'Defaults to %dx%d if unspecified.' % [
          defaults[:size].w * 2,
          defaults[:size].h * 2,
        ]
      ) do |val|
        md = val.match(/^(?<w>\d+)x(?<h>\d+)$/)
        raise "invalid size: #{val}" unless md
        @size = ::TeslaCam::Size.new(md[:w].to_i / 2, md[:h].to_i / 2)
      end

      o.on(
        '--font-size [SIZE]', Integer,
        'Font size.',
        'Defaults to %d if unspecified.' % [defaults[:font_size]]
      ) do |val|
        raise "invalid font size: #{val}" if val < 1
        @font_size = val
      end

      o.on(
        '--bg-color [COLOR]', Integer,
        'Background color.',
        'Defaults to %s if unspecified.' % [defaults[:missing_color]]
      ) do |val|
        @missing_color = val
      end

      o.on(
        '-t', '--title [TITLE]', String,
        'Video title.',
        'Defaults to "" if unspecified.'
      ) do |val|
        @title = val
      end

      presets = ::TeslaCam::CLI::Presets.list.join(', ')
      o.on(
        '-p', '--preset [name]', String,
        'Use preset.',
        'One of: %s.' % [::TeslaCam::CLI::Presets.list.join(', ')]
      ) do |val|
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
