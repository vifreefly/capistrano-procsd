
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name     = "capistrano-procsd"
  spec.version  = "0.2.1"
  spec.authors  = ["Victor Afanasev"]
  spec.email    = ["vicfreefly@gmail.com"]

  spec.summary      = "Capistrano integration for Procsd"
  spec.description  = "Capistrano integration for Procsd"
  spec.homepage     = "https://github.com/vifreefly/capistrano-procsd"
  spec.license      = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", "~> 3.1"
  spec.add_dependency "sshkit-sudo", "~> 0.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
