$:.push File.expand_path("../lib", __FILE__)

# SEE ALSO
# https://github.com/fiedl/your_platform/blob/master/your_platform.gemspec

# Maintain your gem's version:
require "your_platform/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "your_platform"
  s.version     = YourPlatform::VERSION

  s.authors     = [ "Sebastian Fiedlschuster" ]
  s.email       = [ "sebastian@fiedlschuster.de" ]
  s.homepage    = "https://github.com/fiedl/your_platform"

  s.summary     = "Administrative and social network platform for closed user groups."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  # Dependencies 
  # --------------------------------------------------------------------------------

  # Rails and Rails Additions
  s.add_dependency "rails", "~> 3.2"
  s.add_dependency 'rack-ssl', '>= 1.3.4'
  s.add_dependency "rails-i18n"                                                        # MIT License
  s.add_dependency "strong_parameters"                                                 # MIT License
  s.add_dependency "activerecord", '~> 3.2.20'
  s.add_dependency "railties", '~> 3.2.20'

  # JavaScript 
  s.add_dependency "jquery-rails"
  s.add_dependency "jquery-ui-rails", '~> 4.2.0'                                       # MIT, GPL2
  s.add_dependency "sprockets", '~> 2.2.3' # TODO: Update to cover CVE-2014-7819

  # Data Structures
  # DAG Structure, https://github.com/resgraph/acts-as-dag
  s.add_dependency 'acts-as-dag', '>= 2.5.7'                                           # MIT License
  s.add_dependency 'acts_as_tree'                                                      # MIT License
  
  # Caching
  s.add_dependency 'redis-rails'

  # Authentification
  s.add_dependency 'devise', '~> 2.2.8'                           # MIT License

  # Authorization
  s.add_dependency 'cancan'                                                            # MIT License

  # To use ActiveModel has_secure_password (password encryption)
  s.add_dependency 'bcrypt', '>= 3.0.1'                                                # MIT License 

  # Template Engines
  # haml template language, http://haml.info
  s.add_dependency 'haml'                                                              # MIT License
  s.add_dependency 'redcarpet'  # for Markdown                                         # MIT License
  
  # Layout: Twitter Bootstrap
  s.add_dependency 'twitter-bootstrap-rails', '~> 2.2.7'                                  # MIT License
  s.add_dependency 'less', '>= 2.2.0'
  s.add_dependency 'less-rails', '>= 2.2.6'
  # s.add_dependency 'bootstrap-sass'                                                  # Apache License 2.0
  s.add_dependency 'font-awesome-rails', '3.2.1.1'

  # In Place Editing
  s.add_dependency 'best_in_place', '~> 2.1.0'                                         # MIT License
  s.add_dependency 'delocalize'
  
  # Geo Coding
  s.add_dependency 'geocoder'                                                          # MIT License
  s.add_dependency 'gmaps4rails', '2.0.1'                                       # MIT License

  # Formtastic Form Helper,
  # see: https://github.com/justinfrench/formtastic,
  # http://rubydoc.info/gems/formtastic/frames
  s.add_dependency 'formtastic'                                                        # MIT License

  # File Uploads
  s.add_dependency 'carrierwave'                                                       # MIT License
  s.add_dependency 'mini_magick'
  s.add_dependency 'jquery-fileupload-rails'

  # Gravatar image, see: https://github.com/mdeering/gravatar_image_tag
  s.add_dependency 'gravatar_image_tag'                                                # MIT License

  # Edit Mode
  s.add_dependency 'edit_mode', '>= 1.0.0'                                             # MIT License

  # Hide slim breadcrumb elements until user hovers the separator
  s.add_dependency 'slim_breadcrumb', '>= 0.0.3'                                       # MIT License
  
  # Workflow Kit
  s.add_dependency 'workflow_kit', '~> 0.0.7'                                          # MIT License

  # View Helpers
  s.add_dependency 'phony'                                         
  s.add_dependency 'will_paginate', '> 3.0'
  s.add_dependency 'rails-gallery', '>= 0.3.3'                                         # MIT License
  
  # Metrics
  s.add_dependency 'fnordmetric'                                                       # MIT License
  s.add_dependency 'rack-mini-profiler', '>= 0.9.0.pre'                                # MIT License
  
  # Activity Feed
  s.add_dependency 'public_activity', '~> 1.4.1'                                       # MIT License
  
  # XLS Export
  s.add_dependency 'to_xls'
  
  # PDF Export
  s.add_dependency 'prawn'
  
  # ICS Export (iCal)
  s.add_dependency 'icalendar'

  # Development Dependencies 
  # --------------------------------------------------------------------------------

  s.add_development_dependency "rspec-rails", "2.10.0"
  s.add_development_dependency "guard", "1.0.1"
  s.add_development_dependency "guard-rspec", "0.5.5"

end
