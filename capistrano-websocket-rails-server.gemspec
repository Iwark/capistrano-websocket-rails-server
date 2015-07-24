# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/websocket_rails_server/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-websocket-rails-server"
  gem.version       = Capistrano::WebsocketRailsServer::VERSION
  gem.authors       = ["Iwark"]
  gem.email         = ["iwark02@gmail.com"]
  gem.description   = <<-EOF.gsub(/^\s+/, '')
    Restart websocket-rails standalone server only when any related files were changed since last release.
    Works *only* with Capistrano 3+.
  EOF
  gem.summary       = "Restart websocket-rails standalone server only when any related files were changed since last release."
  gem.homepage      = "https://github.com/Iwark/capistrano-websocket-rails-server"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "capistrano", ">= 3.1"
  gem.add_development_dependency "rake"
end