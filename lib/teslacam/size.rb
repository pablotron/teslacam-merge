class TeslaCam::Size < Struct.new(:w, :h)
  def to_s
    "#{w}x#{h}"
  end
end
