class TeslaCam::Model
  attr :config,
       :videos,
       :times,
       :paths,
       :filter,
       :command

  #
  # Format string for ISO-8601 timestamps.
  #
  TIME_FORMAT = '%<year>s-%<month>s-%<day>sT%<hour>s:%<min>s:%<sec>s'

  #
  # Regular expression to extract relevant data from video file names.
  #
  VIDEO_PATH_RE = %r{^
    (?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})_
    (?<hour>\d{2})-(?<min>\d{2})-(?<sec>\d{2})-
    (?<name>[a-z_]+)\.mp4
  $}mx

  #
  # list of camera symbols
  #
  CAMS = %i{front back left_repeater right_repeater}

  def initialize(config)
    # cache config
    @config = config

    # extract video sets from input file names
    @videos = parse_inputs(config.inputs)
    @times = @videos.keys.sort
    @paths = get_paths(@times, @videos)
    @filter = TeslaCam::Filter.new(self)
    @command = get_command(config, @paths, @filter)
  end

  #
  # Are there multiple video sets?
  #
  def multiple_video_sets?
    @videos.keys.size > 1
  end

  private

  #
  # extract video sets from input file names
  #
  def parse_inputs(inputs)
    # extract video sets from input file names
    videos = inputs.each.with_object(Hash.new { |h, k| h[k] = {} }) do |path, r|
      if md = ::File.basename(path).match(VIDEO_PATH_RE)
        # build data
        data = (md.names.each.with_object({}) { |s, mr|
          i = s.intern
          mr[i] = md[i]
        }).merge({
          path: path,
        })

        # build key
        key = TIME_FORMAT % data
        r[key][md[:name].intern] = data
      end
    end

    # check for missing videos in each set
    videos.each do |time, videos|
      missing = CAMS - videos.keys
      if missing.size > 0
        raise "missing videos in #{time}: #{missing * ', '}"
      end
    end

    # return videos
    videos
  end

  #
  # Build ordered list of video input paths.
  #
  def get_paths(times, videos)
    times.reduce([]) do |r, time|
      CAMS.reduce(r) do |r, cam|
        r << videos[time][cam][:path]
      end
    end
  end

  #
  # build ffmpeg command
  #
  def get_command(config, paths, filter)
    [
      config.ffmpeg,

      # hide ffmpeg banner
      '-hide_banner',

      # sorted list of videos (in order of CAMS, see above)
      *(paths.map { |path| ['-i', path] }.flatten),

      # filter command
      '-filter_complex', filter.to_s,
      '-c:v', 'libx264',

      # output path
      config.output,
    ]
  end
end
