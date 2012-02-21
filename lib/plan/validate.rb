module Plan
  class Validate
    require 'open3'

    attr_reader :domain_file, :problem_file, :solution_file,
      :first_quality, :second_quality, :output, :time, :steps

    def initialize(params)
      @domain_file    = params[:domain_file]
      @problem_file   = params[:problem_file]
      @solution_file  = params[:solution_file]
      @validator      = params[:validator] || '/home/rob/dev/Kings/distplantester/VAL-4.2.08/validate'
      @tolerance      = params[:tolerance]

      unless File.executable? @validator
        raise "#{@validator} is not executable"
      end

      unless File.readable? @domain_file
        raise "#{@domain_file} is not readable"
      end

      unless File.readable? @problem_file
        raise "#{@problem_file} is not readable"
      end

      unless File.readable? @solution_file
        raise "#{@solution_file} is not readable"
      end
    end

    def parse()
      @steps = 0;
      @time  = -1;
      file = File.open(@solution_file)
      while (l = file.gets)
        case l
        when /^\s*;\s*time\s*(\d+)/i
          @time = $1.to_i
        when /^\s*;/
          'comment'
        when /\d/
          @steps = @steps + 1
        when /^\(/
          @steps = @steps + 1
        else 
          raise "Don't know how to parse: "+l
        end
      end
    end

    def validate()
      stdout  = self.run_validate("-t #{@tolerance}")
      @first_quality = self.read_quality_value(stdout).to_i
      stdout  = self.run_validate("-t #{@tolerance} -g")
      @second_quality = self.read_quality_value(stdout).to_i
    end

    def read_quality_value(output)
      match = /Final value:\s(\d+)\s*/.match(output)
      if match.nil?
        @output = output
        raise Plan::Validate::Error
      else
        return match.captures.first
      end
    end

    def run_validate(flags)
      cmd = "#{@validator} #{flags} #{@domain_file} #{@problem_file} #{@solution_file}"
      stdin, stdout, stderr = Open3.popen3(cmd)

      if stderr = stderr.readlines.join and  stderr.length > 0
        @output = (stdout.readlines.join) + "\nCMD:#{cmd}\nSTDERR:\n" + stderr
        raise Plan::Validate::ExecutionError
      end

      return stdout.readlines.join
    end

  end

  class Validate::Error < RuntimeError; end
  class Validate::ExecutionError < RuntimeError; end
end
