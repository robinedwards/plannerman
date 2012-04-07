module Plan
  class Import
    attr_reader :domain_name, :domain_directory, :soln_path, :problem_number, :problem_path, :source, :validated_ok

    def initialize(params)
      @planner          = params[:planner]
      @source           = params[:planner]
      @domain_base_dir  = params[:domain_base_dir]
      @domain_name      = params[:domain_name]
      @domain_directory = params[:domain_directory]
      @problem_number   = params[:problem_number]
      @soln_path        = params[:soln_path]
      @validated_ok = 0;

      self.find_domain_file_path

      unless File.readable? @soln_path
        raise "#{@soln_path} is not readable"
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

    def find_domain_file_path
      @domain_file_path = [@domain_base_dir, @domain_directory, 'domain.pddl'].join('/')
      unless File.exist? @domain_file_path
        @domain_file_path = [@domain_base_dir, @domain_directory, 'domain01.pddl'].join('/')
      end
      unless File.exist? @domain_file_path
        raise "#{@domain_file_path} is not a file"
      end
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
        @validated_ok = 1;
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

end
