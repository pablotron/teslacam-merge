require 'optparse'

#
# Parse config from command-line arguments
#
module TeslaCam::CLI::Presets
  PRESETS = {
    full: {
      size: [2560, 1920],
      font_size: 32,
    },

    # x0.75
    large: {
      size: [1920, 1440],
      font_size: 32,
    },

    # x0.5625
    medium: {
      size: [1440, 1080],
      font_size: 24,
    },

    # x0.5
    half: {
      size: [1280, 960],
      font_size: 18,
    },

    # x0.25
    small: {
      size: [640, 480],
      font_size: 16,
    },
  }

  def self.get(s)
    id = s.intern
    raise "unknown preset: #{s}" unless PRESETS.key?(id)
    PRESETS[id]
  end

  def self.list
    PRESETS.keys.map { |v| v.to_s }.sort
  end
end
