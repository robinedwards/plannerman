require 'find'

namespace :import do

  desc "Import requirements from domains in DOMAIN_DIRECTORY"
  task :requirements => :environment do
    ActiveRecord::Base.transaction do
      requirement = {}

      Find.find(ENV['DOMAIN_DIRECTORY']).grep(/domain\d+\.pddl$/) do |domain_path|
        domain = IO.read(domain_path).gsub(/;.+$/, '') # strip comments
        unless m = /\(:requirements\s*([\s\:\w\-]+)\s*\)/im.match(domain)
          puts "no requirements found in #{domain_path} skipping"
          next
        end
        m.captures[0].gsub(':', '').split(/[\s\n]+/).each { |k| k.strip!; requirement[k] = 1 }
      end

      requirement.keys.each { |r| puts "Found #{r}"; Requirements.find_or_create_by_name(r).save! }
    end
  end

end
