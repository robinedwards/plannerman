require 'find'
require 'plan/validate'
require 'pp'

def lookup_problem(problem_name, domain)
  problem_number = /pfile(\d+)/.match(problem_name).captures.first
  problem_name   = sprintf("pfile%02d.pddl", problem_number)

  problem = Problem.find_or_create_by_name_and_domain_id(problem_name, domain.id)

  if problem.description.nil?
    problem_path = [ENV['DOMAIN_DIRECTORY'], domain.directory, problem_name].join('/')
    unless File.exists? problem_path
      raise "No such file " + problem_path
    end
    problem.description = IO.read(problem_path).strip
  end

  problem.save!
  return problem
end

# utility functions
def _import_solution(params)
  domain = Domain.find_or_create_by_name(:name => params[:domain], :directory => params[:domain_directory], :file => 'domain.pddl')
  domain.requirements =  params[:requirements]
  domain.save!

  planner = Planner.find_or_create_by_name(params[:planner], :version => '?')
  planner.save!
  problem = lookup_problem(params[:problem], domain)

  plan = Plan::Validate.new({
    :tolerance      => 0.01,
    :domain_file    => ENV['DOMAIN_DIRECTORY']+'/'+domain.path,
    :problem_file   => ENV['DOMAIN_DIRECTORY']+'/'+problem.path,
    :solution_file  => params[:soln_path],
  });

  begin
    plan.validate
    fq = plan.first_quality
    sq = plan.second_quality
    notes = ''
  rescue Plan::Validate::Error
    puts 'invalid plan'
    fq = -1
    sq = -1
    notes = plan.output
  rescue Plan::Validate::ExecutionError
    puts 'execution error'
    fq = -2
    sq = -2
    notes = plan.output
  end

  plan.parse

  Solution.new(
    :domain       => domain,
    :planner      => planner,
    :source       => ENV['SOURCE'],
    :problem      => problem,
    :steps        => plan.steps,
    :notes        => notes,
    :time         => plan.time,
    :plan_quality             => fq,
    :second_plan_quality      => sq,
    :full_raw_output          => IO.read(params[:soln_path]).strip
  ).save!

  puts params[:soln_path] + " imported ok"
end

def _requirements_filter(req)
  reqmap = {
    'fluents' => 'numeric_fluents' # as of 2008 fluents renamed to numeric_fluents
  };

  req.map{ |r| ( reqmap.has_key? r ) ? reqmap[r] : r }
    .grep(/(?!strip)/)
    .map{ |r| req = Requirement.find_or_create_by_name(r); req.save!; req }
end

def _get_domain_requirements(domain_path)
  unless File.exists? domain_path
    puts "Couldn't find #{domain_path}"
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
        domain_directory = domain.join.downcase
        domain = domain.join(' ')

        unless domain_requirements.has_key? domain
          requirements = _get_domain_requirements(ENV['DOMAIN_DIRECTORY']+'/'+domain_directory+'/domain.pddl')
          domain_requirements[domain] = _requirements_filter(requirements)
        end

        _import_solution({
          :planner      => planner,
          :problem      => problem.downcase,
          :requirements => domain_requirements[domain],
          :notes        => notes,
          :domain       => domain,
          :soln_path    => soln_path,
          :domain_directory  => domain_directory
        })
      end
    end
  end
end
