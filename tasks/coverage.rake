namespace :doc do

  desc 'Print Coverage of the api blueprint with rails routes'
  task :coverage => :environment do
    ApiBluerails.coverage
  end

end