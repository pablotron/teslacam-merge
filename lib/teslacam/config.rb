#
# Parse command-line arguments into config
#
class TeslaCam::Config
  attr :ffmpeg,
       :output,
       :inputs,
       :size,
       :font_size

  def initialize
    @ffmpeg = '/usr/bin/ffmpeg'
  end
end
