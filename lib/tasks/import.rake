require 'find'
require 'plan/validate'
require 'plan/imprt'
require 'pp'

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

        Plan::Import.new({
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
      results = {}
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
        unless parts.first == 'airport'
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

        domain_directory_map = {
          "airportstrips"                         => "airport",
          "airporttimewindowsadltilstemporal"     => "airportadltimewindows",
          "airporttimewindowsstripstilstemporal"  => "airportstripstimewindows",
          "airporttimewindowscostripstemporal"    => 'airportstripstimewindowscompiled',
          "pipesnotankagedeadlinestilstemporal"   => "pipesnotankagedeadlinestils",
          "pipesnotankagedeadlinescotemporal"     => "pipesnotankagedeadlinescompiled",
          "opticaltelegraphdpsadldps"             => "opticaltelegraphdpsadl",
          "opticaltelegraphdpsdps"                => "opticaltelegraphdps",
          "philosophersfluentsadl"                => "philosophersfluentsdpsadl",
          "psrlargeadldps"                        => "psrlargeadl",
          "psrmiddleadldps"                       => "psrmiddledpsadl",
          "psrmiddlecoadl"                        => "psrmiddlecompiledadl",
          "satellitecomplextemporalfluents"                 => "satellitecomplex",
          "satellitecomplextimewindowstilstemporalfluents"  => "satellitecomplextimewindows",
          "satellitecomplextimewindowscotemporalfluents"    => "satellitecomplextimewindowscompiled",
          "satellitenumericfluents"                         => "satellitenumeric",
          "satellitetimetemporal"                           => "satellitetimeipc4",
          "satellitetimetimewindowstilstemporal"            => "satellitetimetimewindows",
          "satellitetimetimewindowscotemporal"              => "satellitetimetimewindowscompilde",
          "settlersipc3fluents"                             => "settlersnumeric",
          "umtsflawtemporalfluents"                         => "umtsflawtemporal",
          "umtsflawtimewindowstilstemporalfluents"          => "umtsflawtimewindowsfluentstil",
          "umtsflawtimewindowscotemporalfluents"            => "umtsflawtimewindowscompiled",
          "umtstimewindowstilstemporalfluents"              => "umtstimewindowstil",
          "umtstimewindowscotemporalfluents"                => "mtstimewindowscompiledtemporalfluents"
        }
        i = {:problem => problem_number, :planner_name => planner_name, :domain_directory => domain_directory, :domain_name => domain_name }

        domain_directory =(domain_directory_map.has_key? domain_directory) ? domain_directory_map[domain_directory] : domain_directory

          if results[domain_directory] == nil
            results[domain_directory] = { 'validated' => 0, 'failed' => 0 }
          end

        if Dir.exists?(ENV['DOMAIN_DIRECTORY']+'/'+domain_directory)
          p domain_directory + ' OK'
          planner = Planner.find_or_create_by_name(planner_name, :version => '?')
          planner.save!

          plan = Plan::Import.new({
            :planner => planner,
            :source  => 'IPC 2004',
            :domain_base_dir  => ENV['DOMAIN_DIRECTORY'],
            :domain_name      => domain_name,
            :domain_directory => domain_directory,
            :problem_number   => problem_number,
            :soln_path        => soln_path
          })

          plan.import


          if plan.validated_ok
            results[domain_directory]['validated'].succ
          else
            results[domain_directory]['failed'].succ
          end
        else
            results[domain_directory]['failed'].succ
        end
      end
      pp results
    end
  end
end
