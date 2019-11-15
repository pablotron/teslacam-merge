require 'time'

class TeslaCam::Filter
  def initialize(model)
    num_times = model.times.size

    w = model.config.size.w
    h = model.config.size.w
    font = get_font(model.config)

    # build filter clause
    @s = model.times.each_with_index.map { |time, i|
      # extract timestamp from key
      ts = Time.parse(time)

      # build sink id
      sink = (num_times > 1) ? "[v#{i}]" : ''

      "
        nullsrc=size=#{w*2}x#{h*2}:duration=60 [v#{i}_bg];
        [#{4 * i + 0}:v] setpts=PTS-STARTPTS, scale=#{w}x#{h} [v#{i}_tl];
        [#{4 * i + 1}:v] setpts=PTS-STARTPTS, scale=#{w}x#{h} [v#{i}_tr];
        [#{4 * i + 2}:v] setpts=PTS-STARTPTS, scale=#{w}x#{h} [v#{i}_bl];
        [#{4 * i + 3}:v] setpts=PTS-STARTPTS, scale=#{w}x#{h} [v#{i}_br];
        [v#{i}_bg][v#{i}_tl] overlay=shortest=0 [v#{i}_t0];
        [v#{i}_t0][v#{i}_tr] overlay=shortest=0:x=#{w} [v#{i}_t1];
        [v#{i}_t1][v#{i}_bl] overlay=shortest=0:y=#{h} [v#{i}_t2];
        [v#{i}_t2][v#{i}_br] overlay=shortest=0:x=#{w}:y=#{h} [v#{i}_t3];
        [v#{i}_t3] drawtext=text=front:x=4:y=3:#{font} [v#{i}_t4];
        [v#{i}_t4] drawtext=text=back:x=(w-text_w-4):y=3:#{font} [v#{i}_t5];
        [v#{i}_t5] drawtext=text=left:x=4:y=(h-text_h-3):#{font} [v#{i}_t6];
        [v#{i}_t6] drawtext=text=right:x=(w-text_w-4):y=(h-text_h-3):#{font} [v#{i}_t7];
        [v#{i}_t7] drawtext=text=%{pts\\\\:localtime\\\\:#{ts.to_i}}:x=(w-text_w)/2:y=(h-text_h-5):#{font} #{sink}
      "
    }.concat((num_times > 1) ? [
      '%s concat=n=%d' % [
        num_times.times.map { |i| "[v#{i}]" }.join(''),
        num_times,
      ],
    ] : []).join(';').freeze
  end

  def to_s
    @s
  end

  private

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
end
