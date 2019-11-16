require 'time'

class TeslaCam::Filter
  def initialize(model)
    config = model.config
    num_times = model.times.size

    # build filter string
    @s = model.times.each_with_index.map { |time, i|
      [
        # get null source and video source nodes
        sources(i, model, time),

        # get overlay nodes
        overlays(i, config),

        # get text overlay nodes
        texts(i, config, time, num_times),
      ]
    }.flatten.concat(
      # get concatenate node
      concat_expr(num_times)
    ).join(';').freeze

    # puts @s
    # exit 0
  end

  def to_s
    @s
  end

  private

  QUADS = {
    tl: :front,
    tr: :back,
    bl: :left_repeater,
    br: :right_repeater,
  }

  #
  # Get video sources.
  #
  def sources(i, model, time)
    # get missing color and quad size from config
    color = model.config.missing_color
    w = model.config.size.w
    h = model.config.size.h

    # build map of quad ID to argument number of corresponding video
    # on command-line
    lut = QUADS.keys.reduce({
      # get command line argument offset for files in this set
      ofs: i.times.reduce(0) do |r, j|
        r + model.videos[model.times[j]].size
      end,

      args: []
    }) do |r, id|
      if model.videos[time][QUADS[id]]
        r[:args] << { id: id, ofs: r[:ofs] }
        r[:ofs] += 1
      end
      r
    end[:args].each.with_object({}) do |row, r|
      r[row[:id]] = row[:ofs]
    end

    # build null sources
    [
      "nullsrc=size=#{w*2}x#{h*2}:d=60, drawbox=c=#{color}:t=fill [v#{i}_bg]",
    ].concat((QUADS.keys - lut.keys).map { |id|
      # missing video
      "nullsrc=size=#{w}x#{h}:d=60 [v#{i}_#{id}]"
    }).concat(lut.map { |id, ofs|
      # command-line argument source
      "[#{ofs}:v] setpts=PTS-STARTPTS, scale=#{w}x#{h} [v#{i}_#{id}]"
    }).join(';')
  end

  #
  # Ordered list of video overlays.
  #
  OVERLAYS = [{
    srcs: %w{bg tl},
    dst: 't0',
    x: 0,
    y: 0,
  }, {
    srcs: %w{t0 tr},
    dst: 't1',
    x: 1,
    y: 0,
  }, {
    srcs: %w{t1 bl},
    dst: 't2',
    x: 0,
    y: 1,
  }, {
    srcs: %w{t2 br},
    dst: 't3',
    x: 1,
    y: 1,
  }]

  #
  # Video overlay format string.
  #
  OVERLAY_FORMAT = '
    [v%<i>d_%<src0>s][v%<i>d_%<src1>s]
    overlay=shortest=0:x=%<x>d:y=%<y>d
    [v%<i>d_%<dst>s]
  '.gsub(/[\s\n]+/mx, ' ').strip.freeze

  #
  # Get video overlays.
  #
  def overlays(i, config)
    w = config.size.w
    h = config.size.h

    OVERLAYS.map { |row|
      OVERLAY_FORMAT % row.merge({
        src0: row[:srcs].first,
        src1: row[:srcs].last,
        i: i,
        x: row[:x] * w,
        y: row[:y] * h,
      })
    }.join(';')
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
  }, {
    text: '%<title>s',
    x:    '(w-text_w)/2',
    y:    '3',
  }]

  #
  # Get text overlays
  #
  def texts(i, config, time, num_times)
    # get font
    font = get_font(config)

    # build text args
    text_args = {
      # timestamp offset
      ts: Time.parse(time).to_i,

      # video title
      title: config.title, # FIXME: need to escape this
    }

    # build and return result
    '[v%<i>d_t3] %<texts>s %<sink>s' % {
      i: i,

      texts: TEXTS.map { |row|
        'drawtext=text=%<text>s:x=%<x>s:y=%<y>s:%<font>s' % row.merge({
          text: row[:text] % text_args,
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
