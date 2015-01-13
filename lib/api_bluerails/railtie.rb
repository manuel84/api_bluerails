# encoding: UTF-8
require 'api_bluerails'
require 'rails'
# Api Bluerails railties
module ApiBluerails
  # class for extending rails rake tasks
  class Railtie < Rails::Railtie
    rake_tasks do
      filename = File.dirname(__FILE__), '..', '..', 'tasks', 'coverage.rake'
      load File.join filename
      # load 'tasks/uml.rake'
    end
  end
end
