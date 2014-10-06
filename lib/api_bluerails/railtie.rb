require 'api_bluerails'
require 'rails'
module ApiBluerails
  class Railtie < Rails::Railtie
    rake_tasks do
      f = File.join(File.dirname(__FILE__), '..', '..', 'tasks', 'coverage.rake')
      load f
      # load 'tasks/uml.rake'
    end
  end
end