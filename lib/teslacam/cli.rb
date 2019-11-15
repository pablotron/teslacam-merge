require 'pp'

#
# Command-line interface.
#
module TeslaCam::CLI
  LIB_DIR = File.join(__dir__, 'cli').freeze
  autoload :Config, File.join(LIB_DIR, 'config.rb')

  def self.run(app, args)
    # get config from command-line, build model
    config = ::TeslaCam::CLI::Config.new(app, args)
    model = ::TeslaCam::Model.new(config)

    # exec command
    # pp model.command
    ::Kernel.exec(*model.command)
  end
end
