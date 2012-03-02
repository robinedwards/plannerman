require 'find'
require 'plan/validate'
require 'pp'

class Plan::Importer
  attr_reader :domain_name, :domain_directory, :soln_path, :problem_number, :problem_path, :source

  def initialize(params)
    @planner          = params[:planner]
    @source           = params[:planner]
    @domain_base_dir  = params[:domain_base_dir]
    @domain_name      = params[:domain_name]
    @domain_directory = params[:domain_directory]
    @problem_number   = params[:problem_number]
    @soln_path        = params[:soln_path]

    @domain_file_path = [@domain_base_dir, @domain_directory, 'domain.pddl'].join('/')

    unless File.readable? @soln_path
      raise "#{@soln_path} is not readable"
    end

    unless Dir.exist? @domain_base_dir
      raise "#{@domain_file_path} is not a directory"
    end

    unless File.readable? @domain_file_path
      raise "#{@domain_file_path} is not readable"
    end
  end

  def import
    self.find_or_import_requirements
    self.find_or_import_domain
    self.find_or_import_problem
    self.validate_plan
    self.import_plan
  end

  def find_or_import_requirements
    domain_description = IO.read(@domain_file_path).gsub(/;.+$/, '') # strip comments
    unless m = /\(:requirements\s*([\s\:\w\-]+)\s*\)/im.match(domain_description)
      return []
    end

    requirements =  m.captures[0].gsub(':', '').split(/\s+/).map { |k| k.strip }

    # filter requirements
     reqmap = {
      'fluents' => 'numeric_fluents' # as of 2008 fluents renamed to numeric_fluents
    };

    @requirements = requirements.map{ |r| ( reqmap.has_key? r ) ? reqmap[r] : r }
      .grep(/(?!strip)/)
      .map{ |r| r = Requirement.find_or_create_by_name(r); r.save!; r }
  end

  def find_or_import_domain
    @domain = Domain.find_or_create_by_name(:name => @domain_name, :directory => @domain_directory, :file => 'domain.pddl')

    unless @requirements.nil?
      @domain.requirements = @requirements
    end

    @domain.save!
  end

  def find_or_import_problem
    problem_name = sprintf("pfile%02d.pddl", @problem_number)

    @problem = Problem.find_or_create_by_name_and_domain_id(problem_name, @domain.id)
    @problem_file_path = [@domain_base_dir, @domain.directory, problem_name].join('/')

    if @problem.description.nil?
      unless File.exists? @problem_file_path
        raise "No such problem file " + @problem_file_path
      end
      @problem.description = IO.read(@problem_file_path).strip
    end

    @problem.save!
  end

  def validate_plan
    @plan = Plan::Validate.new({
      :tolerance      => 0.01,
      :domain_file    => @domain_file_path,
      :problem_file   => @problem_file_path,
      :solution_file  => @soln_path,
    });

    begin
      @plan.validate
    rescue Plan::Validate::Error
      puts "validator output error, invalid plan?: #{@soln_path} output:\n#{@plan.output}"
    rescue Plan::Validate::ExecutionError
      puts "validator execution error for: #{@soln_path} output:\n#{@plan.output}"
    end

    @plan.parse
  end

  def import_plan
    Solution.new(
      :domain       => @domain,
      :planner      => @planner,
      :source       => @source,
      :problem      => @problem,
      :steps        => @plan.steps,
      :notes        => @plan.output,
      :time         => @plan.time,
      :plan_quality             => @plan.first_quality,
      :second_plan_quality      => @plan.second_quality,
      :full_raw_output          => IO.read(@soln_path).strip
    ).save!

    puts "imported #{@soln_path}"
  end
end

namespace :import do

  task :ipc_2003_results => :environment do
    ActiveRecord::Base.transaction do

      Find.find(ENV['PLAN_DIRECTORY']).grep(/soln$/) do |soln_path|

        next if soln_path.downcase.include? 'handcoded'
        parts   = soln_path.sub(ENV['PLAN_DIRECTORY'], '').split('/')
        problem = parts.pop.split('.').first
        planner = parts.shift
        notes   = parts.shift
        domain  = parts.map{ |i|
          i.sub(/zenotravel/i, 'zeno').sub(/hardnumeric/i, 'numeric').capitalize
        }.delete_if{|i| i == 'Strips'}

        planner = Planner.find_or_create_by_name(planner, :version => '?')
        planner.save!

        problem_number = /pfile(\d+)/.match(problem).captures.first

        Plan::Importer.new({
          :planner => planner,
          :source  => 'IPC 2003',
          :domain_base_dir  => ENV['DOMAIN_DIRECTORY'],
          :domain_name      => domain.join(' '),
          :domain_directory => domain.join.downcase,
          :problem_number   => problem_number,
          :soln_path        => soln_path
        }).import

      end
    end
  end

  task :ipc_2004_results => :environment do
    ActiveRecord::Base.transaction do
      no_exist = {}
      Find.find(ENV['PLAN_DIRECTORY']).grep(/SOLN$/) do |soln_path|
        parts     = soln_path.sub(ENV['PLAN_DIRECTORY'], '').split('/')
        problem_number    = /(\d+)/.match(parts.pop).captures.first.to_i
        planner_name      = parts.pop

        parts2 = []
        parts.each do |i|
          i.downcase!
          parts2.concat(i.split(/_|\s+/))
        end

        parts = parts2.uniq;
        unless parts[first] == 'airport'
          parts.delete('strips')
        end
        parts.delete('nontemporal')

        if parts.first == 'pipesworld'
          parts[0] = 'pipes'
        elsif parts.first == 'promela'
          parts.shift
        end

        if parts.index('temporal') != nil
          parts.delete('temporal')
          if parts.index('fluents')
            parts.delete('fluents')
            parts.push('temporal', 'fluents')
          else
            parts.push('temporal')
          end
        end

        rewrite_map = {
          'timedli' => 'tils',
          'timedliterals' => 'tils',
          'compiled' => 'co',
          'compi' => 'co',
          'derivedpredicates' => 'dps',
          'derivedpredic' => 'dps',
        }

        domain_directory  = parts.map {|l| ( rewrite_map.has_key? l ) ? rewrite_map[l] : l  }.join
        domain_name       = parts.map {|i| i.capitalize}.join(' ')

        i = {:problem => problem_number, :planner_name => planner_name, :domain_directory => domain_directory, :domain_name => domain_name }

        unless Dir.exists?(ENV['DOMAIN_DIRECTORY']+'/'+domain_directory)
          no_exist[domain_directory] = domain_name
        else
       #   p domain_directory + ' OK'
        end
      end
      pp no_exist.keys.count, no_exist
    end
  end
end
