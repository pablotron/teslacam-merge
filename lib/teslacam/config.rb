#
# Parse command-line arguments into config
#
class TeslaCam::Config
  attr :ffmpeg,
       :quiet,
       :output,
       :inputs,
       :size,
       :font_size,
       :missing_color,
       :title

  DEFAULTS = {
    title: '',
    size: ::TeslaCam::Size.new(320, 240),
    font_size: 16,
    missing_color: 'black',
  }.freeze

  #
  # Create a new Config instance and set defaults.
  #
  def initialize
    # path to ffmpeg command
    @ffmpeg = '/usr/bin/ffmpeg'

    # make ffmpeg only show fatal errors
    @quiet = false

    # video title
    @title = DEFAULTS[:title]

    # output size
    @size = DEFAULTS[:size]

    # font size
    @font_size = DEFAULTS[:font_size]

    # background color for missing videos
    @missing_color = DEFAULTS[:missing_color]
  end
end
