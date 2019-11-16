require 'pp'
require 'logger'

#
# Command-line interface.
#
module TeslaCam::CLI
  LIB_DIR = File.join(__dir__, 'cli').freeze
  autoload :Config, File.join(LIB_DIR, 'config.rb')

  #
  # Run from command-line.
  #
  def self.run(app, args)
    # get config from command-line, build model
    config = ::TeslaCam::CLI::Config.new(app, args)

    # create logger from config
    log = ::Logger.new(config.quiet ? nil : STDERR)

    # create model from config and log
    model = ::TeslaCam::Model.new(config, log)


    # exec command
    log.debug { 'exec: %p' % [model.command] }
    ::Kernel.exec(*model.command)
  end
end
