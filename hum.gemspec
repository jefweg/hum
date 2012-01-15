# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hum/version"

Gem::Specification.new do |s|
  s.name        = "hum"
  s.version     = Hum::VERSION
  s.authors     = ["Jeffrey Wegesin"]
  s.email       = ["jeff@jwegesin.com"]
  s.homepage    = ""
  s.summary     = %q{Generate HTML from your SASS or CSS}
  s.description = %q{Hum generates HTML from your SASS or CSS. View more info at github.com/jefweg/hum}

  s.rubyforge_project = "hum"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'sass', '>= 3.1.12'
  s.add_dependency 'haml', '>= 3.1.4'
  s.add_dependency 'fssm', '>= 0.2.7'
  s.add_dependency 'colored', '>= 1.2'
end
