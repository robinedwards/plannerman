require 'find'
require 'pp'

REQUIREMENTS_MAP = { 
  'fluents' => 'numeric_fluents' # as of 2008 fluents renamed to numeric_fluents
}

# utility functions
def _import_solution(params)
  domain = Domain.find_or_create_by_name(:name => params[:domain], :domain_file => params[:domain_file])
  domain.requirements =  params[:requirements]
  domain.save!
  problem = Problem.find_or_create_by_name_and_domain_id(params[:problem], domain.id)
  problem.save!
  planner = Planner.find_or_create_by_name(params[:planner], :version => '?')
  planner.save!

  soln = _parse_solution(params[:soln_path])

  Solution.new(
    :domain       => domain,
    :planner      => planner,
    :source       => ENV['SOURCE'],
    :problem      => problem,
    :steps        => 99,
    :full_raw_output   => soln[:raw_output]
  ).save!
end

def _parse_solution(path)
  { :raw_output => IO.read(path) }
end

def _requirements_filter(req)
  req.map{ |r| ( REQUIREMENTS_MAP.has_key? r ) ? REQUIREMENTS_MAP[r] : r }
    .grep(/(?!strip)/)
    .map{ |r| req = Requirement.find_or_create_by_name(r); req.save!; req }
end

def _get_domain_requirements(domain_path)
  unless File.exists? domain_path
    p "Couldn't find #{domain_path}"
    return []
  end

  domain = IO.read(domain_path).gsub(/;.+$/, '') # strip comments
  unless m = /\(:requirements\s*([\s\:\w\-]+)\s*\)/im.match(domain)
    return []
  end

  return m.captures[0].gsub(':', '').split(/\s+/).map { |k| k.strip }
end


namespace :import do

  desc "Import requirements from domains in DOMAIN_DIRECTORY"
  task :requirements => :environment do
    ActiveRecord::Base.transaction do
      requirement = {}

      Find.find(ENV['DOMAIN_DIRECTORY']).grep(/domain\d+\.pddl$/) do |domain_path|
        _get_domain_requirements(domain_path).each {|r| requirement[r] =1 }
      end

      requirement.keys.each { |r| puts "Found #{r}"; Requirements.find_or_create_by_name(r).save! }
    end
  end

  desc "Import IPC results"
  task :ipc_results => :environment do
    ActiveRecord::Base.transaction do
      domain_requirements = {}

      Find.find(ENV['PLANS_DIRECTORY']).grep(/soln$/) do |soln_path|
        next if soln_path.downcase.include? 'handcoded'

        parts   = soln_path.sub(ENV['PLANS_DIRECTORY'], '').split('/')
        problem = parts.pop.split('.').first
        planner = parts.shift
        notes   = parts.shift
        domain  = parts.map{ |i|
          i.sub(/zenotravel/i, 'zeno').sub(/hardnumeric/i, 'numeric').capitalize
        }.delete_if{|i| i == 'Strips'}

        # path part
        domain_file = (domain.join.downcase)+'/domain.pddl'
        domain = domain.join(' ')
        unless domain_requirements.has_key? domain
          requirements = _get_domain_requirements(ENV['DOMAIN_DIRECTORY']+'/'+domain_file)
          domain_requirements[domain] = _requirements_filter(requirements)
        end

        _import_solution({
          :planner      => planner,
          :problem      => problem.downcase,
          :requirements => domain_requirements[domain],
          :notes        => notes,
          :domain       => domain,
          :domain_file  => domain_file,
          :soln_path    => soln_path
        })
      end
    end
  end
end
