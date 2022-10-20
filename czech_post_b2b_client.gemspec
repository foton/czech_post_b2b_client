# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'czech_post_b2b_client/version'

github_uri = 'https://github.com/foton/czech_post_b2b_client'

Gem::Specification.new do |spec|
  spec.name          = 'czech_post_b2b_client'
  spec.version       = CzechPostB2bClient::VERSION
  spec.authors       = ['Petr Mlčoch']
  spec.email         = ['foton@centrum.cz']

  spec.summary       = 'Accessing B2B API of Czech Post for bulk processing of packages ("B2B - WS PodáníOnline").'
  spec.homepage      = github_uri
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = github_uri
    spec.metadata['changelog_uri'] = github_uri + '/blob/master/CHANGELOG.md'
    spec.metadata['bug_tracker_uri'] = github_uri + '/issues'
    spec.metadata['documentation_uri'] = github_uri + '/blob/master/doc/index.html'
  else
    msg = <<~MSG
      RubyGems 2.0 or newer is required to protect against public
      gem pushes. You can update your rubygems version by running:\n\n
      gem install rubygems-update\n
      update_rubygems\n
      gem update --system
    MSG
    raise msg
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir['bin/*', 'certs/*', 'doc/**/*', 'lib/**/*'] \
               + ['LICENSE.txt', 'README.md', 'CHANGELOG.md', 'CODE_OF_CONDUCT.md', '.rubocop.yml'] \
               + %w[Rakefile Gemfile]
  # spec.test_files = Dir["{test}/**/*_test.rb"]

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'ox'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'webmock'
end
