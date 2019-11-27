module TeslaCam
  VERSION = '0.2.0'

  LIB_DIR = File.join(__dir__, 'teslacam').freeze

  autoload :CLI, File.join(LIB_DIR, 'cli.rb')
  autoload :Config, File.join(LIB_DIR, 'config.rb')
  autoload :Filter, File.join(LIB_DIR, 'filter.rb')
  autoload :Model, File.join(LIB_DIR, 'model.rb')
  autoload :Size, File.join(LIB_DIR, 'size.rb')
end
