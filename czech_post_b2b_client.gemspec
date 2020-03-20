# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'czech_post_b2b_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'czech_post_b2b_client'
  spec.version       = CzechPostB2bClient::VERSION
  spec.authors       = ['Petr Mlčoch']
  spec.email         = ['foton@centrum.cz']

  spec.summary       = 'Accessing B2B API of Czech Post for bulk processing of packages ("B2B - WS PodáníOnline").'
  spec.homepage      = 'https://github.com/foton/czech_post_b2b_client'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/foton/czech_post_b2b_client'
    spec.metadata['changelog_uri'] = 'https://github.com/foton/czech_post_b2b_client/blob/master/CHANGELOG.md'
    spec.metadata['bug_tracker_uri'] = 'https://github.com/foton/czech_post_b2b_client/issues'
    # spec.metadata['documentation_uri'] = 'https://www.rubydoc.info/gems/czech_post_b2b_client'
  else
    msg = "RubyGems 2.0 or newer is required to protect against public "\
          "gem pushes. You can update your rubygems version by running:\n\n"\
          "gem install rubygems-update\n"\
          "update_rubygems\n"\
          "gem update --system"
    raise msg
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["bin/*","certs/*","doc/**/*","lib/**/*"] \
               + ['LICENSE.txt', 'README.md', 'CHANGELOG.md', 'CODE_OF_CONDUCT.md','.rubocop.yml'] \
               + ['Rakefile', 'Gemfile']
  # spec.test_files = Dir["{test}/**/*_test.rb"]

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'ox', '~> 2.11'

  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 0.80'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.6'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
