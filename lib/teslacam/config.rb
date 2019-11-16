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

  #
  # Create a new Config instance and set defaults.
  #
  def initialize
    # path to ffmpeg command
    @ffmpeg = '/usr/bin/ffmpeg'

    # make ffmpeg only show fatal errors
    @quiet = false

    # video title
    @title = ''

    # output size
    @size = ::TeslaCam::Size.new(320, 240)

    # font size
    @font_size = 16

    # background color for missing videos
    @missing_color = 'black'
  end
end
