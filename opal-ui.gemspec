Gem::Specification.new {|s|
  s.name     = 'opal-ui'
  s.version  = "0.0.0"
  s.author   = 'ppibburr'
  s.email    = 'tulnor33@gmail.com'
  s.homepage = 'http://github.com/ppibburr/opal-ui'
  s.platform = Gem::Platform::RUBY
  s.summary  = 'GUI ToolKit inspired by Gtk for opal'
  s.license  = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'opal-browser'
}
