require_relative './lib/teslacam'

Gem::Specification.new do |s|
  s.name        = 'teslacam-merge'
  s.version     = TeslaCam::VERSION
  s.date        = '2019-11-15'
  s.authors     = ['Paul Duncan']
  s.email       = 'pabs@pablotron.org'
  s.homepage    = 'https://github.com/pablotron/teslacam-merge'
  s.license     = 'MIT'
  s.summary     = 'Combine TeslaCam videos into a single output video.'
  s.description = '
    Combine TeslaCam videos into a single output video.  Allows you to
    set the output video size, and add a title to the output video.
  '

  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/pablotron/teslacam-merge/issues',
    "documentation_uri" => 'https://pablotron.github.io/teslacam-merge/',
    "homepage_uri"      => 'https://github.com/pablotron/teslacam-merge',
    "source_code_uri"   => 'https://github.com/pablotron/teslacam-merge',
    "wiki_uri"          => 'https://github.com/pablotron/teslacam-merge/wiki',
  }

  s.bindir      = 'bin'
  s.executables = 'teslacam-merge'
  s.files = Dir['bin/teslacam-merge', '{lib,test}/**/*.rb'] + %w{
    README.md
    license.txt
    Rakefile
  }
end
