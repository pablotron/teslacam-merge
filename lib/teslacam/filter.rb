require 'time'

class TeslaCam::Filter
  def initialize(model)
    config = model.config
    num_times = model.times.size

    # build filter clause
    @s = model.times.each_with_index.map { |time, i|
      [
        # get null source and video source nodes
        sources(i, config),

        # get overlay nodes
        overlays(i, config),

        # get text overlay nodes
        texts(i, config, time, num_times),
      ]
    }.flatten.concat(
      # get concatenate node
      concat_expr(num_times)
    ).join(';').freeze
  end

  def to_s
    @s
  end

  private

  #
  # Get video sources.
  #
  def sources(i, config)
    w = config.size.w
    h = config.size.h

    # TODO: handle missing videos (e.g., check for front and
    # map it to null source if it doesn't exist)
    "
      nullsrc=size=#{w*2}x#{h*2}:duration=60 [v#{i}_bg];
      [#{4 * i + 0}:v] setpts=PTS-STARTPTS, scale=#{w}x#{h} [v#{i}_tl];
      [#{4 * i + 1}:v] setpts=PTS-STARTPTS, scale=#{w}x#{h} [v#{i}_tr];
      [#{4 * i + 2}:v] setpts=PTS-STARTPTS, scale=#{w}x#{h} [v#{i}_bl];
      [#{4 * i + 3}:v] setpts=PTS-STARTPTS, scale=#{w}x#{h} [v#{i}_br]
    "
  end

  #
  # Get video overlays.
  #
  def overlays(i, config)
    w = config.size.w
    h = config.size.h

    "
      [v#{i}_bg][v#{i}_tl] overlay=shortest=0 [v#{i}_t0];
      [v#{i}_t0][v#{i}_tr] overlay=shortest=0:x=#{w} [v#{i}_t1];
      [v#{i}_t1][v#{i}_bl] overlay=shortest=0:y=#{h} [v#{i}_t2];
      [v#{i}_t2][v#{i}_br] overlay=shortest=0:x=#{w}:y=#{h} [v#{i}_t3]
    "
  end

  #
  # Text overlays.
  #
  TEXTS = [{
    text: 'front',
    x: '4',
    y: '3',
  }, {
    text: 'back',
    x: '(w-text_w-4)',
    y: '3',
  }, {
    text: 'left',
    x: '4',
    y: '(h-text_h-3)',
  }, {
    text: 'right',
    x:    '(w-text_w-4)',
    y:    '(h-text_h-3)',
  }, {
    text: '%%{pts\\\\:localtime\\\\:%<ts>i}',
    x:    '(w-text_w)/2',
    y:    '(h-text_h-5)',
  }]

  #
  # Get text overlays
  #
  def texts(i, config, time, num_times)
    # get timestamp offset and font
    ts = Time.parse(time).to_i
    font = get_font(config)

    # build and return result
    '[v%<i>d_t3] %<texts>s %<sink>s' % {
      i: i,

      texts: TEXTS.map { |row|
        'drawtext=text=%<text>s:x=%<x>s:y=%<y>s:%<font>s' % row.merge({
          text: row[:text] % { ts: ts },
          font: font,
        })
      }.join(', '),

      sink: (num_times > 1) ? "[v#{i}]" : ''
    }
  end

  #
  # Get font config
  #
  def get_font(config)
    [
      'fontcolor=white@0.8',
      "fontsize=#{config.font_size}",

      # 'shadowcolor=black@0.5',
      # 'shadowx=1',
      # 'shadowy=1',

      # 'box=1',
      # 'boxborderw=2',
      # 'boxcolor=black@0.5',

      'borderw=1',
      'bordercolor=black@0.5',
    ].join(':')
  end

  #
  # Get concat statement.
  #
  def concat_expr(num_times)
    (num_times > 1) ? [
      '%s concat=n=%d' % [
        num_times.times.map { |i| "[v#{i}]" }.join(''),
        num_times,
      ],
    ] : []
  end
end
