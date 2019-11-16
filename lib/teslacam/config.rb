#
# Parse command-line arguments into config
#
class TeslaCam::Config
  attr :ffmpeg,
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

    @title = 'test title'

    # background color for missing videos
    @missing_color = 'black'
  end
end
