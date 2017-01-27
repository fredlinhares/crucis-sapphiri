Gem::Specification.new do |s|
  s.name = 'cste'
  s.version = '0.0.0'
  s.default_executable = 'cste'

  s.date = '2017-01-26'
  s.summary = "Text editor."
  s.description = "An extensible, customizable, text editor"
  s.author = "Frederico Linhares"
  s.email = 'fred@linhares.blue'
  s.executables = ["cste"]
  s.files = Dir['README.md', 'LICENSE', 'lib/*', 'lib/core/*',
                'lib/initialize/*', 'bin/cste']
  s.require_paths = ["lib"]
  s.homepage = "https://github.com/fredlinhares/crucis-sapphiri"
  s.license = 'MIT'
end
