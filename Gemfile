# YourPlatform
gem 'your_platform', git: 'https://github.com/fiedl/your_platform', branch: 'sf/rails-5'

source 'https://rubygems.org' do
  # Ruby License, http://www.ruby-lang.org/en/LICENSE.txt
  gem 'rails', '~> 5.0.0'

  gem 'mysql2'	# MIT License

  gem 'web-console', group: :development

  gem 'sass-rails', '>= 4.0.3'
  gem 'uglifier', '>= 1.3.0'  # MIT License
  gem 'coffee-rails', '>= 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more
  # supported runtimes.
  # This is also needed by twitter-bootstrap-rails in production.
  gem 'execjs'
  # But therubyracer apparently uses a lot of memory:
  # https://github.com/seyhunak/twitter-bootstrap-rails/issues/336
  gem 'therubyracer', :platform => :ruby

  # To use Jbuilder templates for JSON
  # gem 'jbuilder'

  # Use unicorn as the app server
  gem 'unicorn'

  # Deploy with Capistrano
  # gem 'capistrano'

  # DAG für Nodes Model, see: https://github.com/resgraph/acts-as-dag
  #gem 'acts-as-dag', path: '../acts-as-dag'
  #gem 'acts-as-dag', git: "git://github.com/resgraph/acts-as-dag.git"	# MIT License
  #gem 'acts-as-dag', '>= 2.5.7'  # now in your_platform


  # JSON
  gem 'json'								# Ruby License

  # Lucene
  # gem 'lucene'								# MIT License

  # Farbiger Konsolen-Output
  gem 'colored'								# MIT License

  # Auto Completion
  #gem 'rails3-jquery-autocomplete'					# MIT Licenses

  # Debug Tools
  group :development do

    # debugger: http://guides.rubyonrails.org/debugging_rails_applications.html
    #gem 'debugger'

    gem 'binding_of_caller'

    gem 'letter_opener'
  end

  # Security Tools
  group :development, :test do
    gem 'brakeman', '>= 2.3.1'
  end

  # Documentation Tools
  group :development, :test do
    gem 'yard'
    gem 'redcarpet'
  end

  # RSpec, see: http://ruby.railstutorial.org/chapters/static-pages#sec:first_tests
  group :test, :development do
    gem 'rspec-rails'
    gem 'rspec-its'
    gem 'parallel_tests'
  #  gem 'rspec-mocks'
  #  gem 'rb-inotify', '0.8.8' if RUBY_PLATFORM.downcase.include?("linux")
  end
  group :test do
    gem 'launchy'
    gem 'factory_girl_rails', '>= 4.0.0' # '1.4.0'
    gem 'database_cleaner'
    gem 'email_spec'
    gem 'timecop'  # time_travel
    gem 'capybara', '2.13.0'
    gem 'selenium-webdriver'
    gem 'poltergeist', '1.11.0'
  end
  group :development do
    gem 'spring'
    gem 'spring-commands-rspec'
  end

  # Pry Console Addon
  group :development, :test do
    gem 'pry'
    gem 'pry-remote'
  end


  # View Helpers
  # gem 'rails-gallery', git: 'https://github.com/kristianmandrup/rails-gallery'

  # Encoding Detection
  gem 'charlock_holmes'

  # readline (for rails console)
  # see https://github.com/luislavena/rb-readline/issues/84#issuecomment-17335885
  #gem 'rb-readline', '~> 0.5.0', group: :development, require: 'readline'

  # To customly set timeout time we need rack-timeout
  gem 'rack-timeout'

  # Profiling
  gem 'flamegraph'
  gem 'stackprof'

  # Maintenance Mode
  gem 'turnout'

  gem 'newrelic_rpm'
  #gem 'jquery-datatables-rails', git: 'git://github.com/rweng/jquery-datatables-rails.git'

  # get emails for exceptions.
  # http://railscasts.com/episodes/104
  gem 'exception_notification'

  #gem 'bootstrap', git: 'https://github.com/twbs/bootstrap-rubygem'

  # Security Fixes
  gem 'rubyzip', '>= 1.2.1'  # CVE-2017-5946
  gem 'nokogiri', '>= 1.7.1'  #  USN-3235-1

  # Temporary Forks and Overrides
  gem 'acts-as-dag', git: 'https://github.com/fiedl/acts-as-dag', branch: 'sf/rails-5'
  gem 'refile', git: 'https://github.com/sobrinho/refile'
  gem 'refile-mini_magick', git: 'https://github.com/refile/refile-mini_magick'
end

source 'https://rails-assets.org'
#source 'https://rails-assets.org' do
#  gem 'rails-assets-tether', '>= 1.1.0'
#end

ruby '2.3.3'
