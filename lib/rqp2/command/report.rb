module RQP2
  class Command
    #
    # Create reports for student submissions
    #
    # SYNOPSIS
    #   rqp2 [options] report
    #
    class Report < Quickl::Command(__FILE__, __LINE__)

      def initialize(*args)
        super
        @year = Time.now.year
      end
      attr_reader :year

      # Parse the options
      options do |opt|
        opt.on('--year=YEAR') do |year|
          @year = Integer(year)
        end
      end

      # Command execution
      def execute(args)
        raise Quickl::InvalidArgument if args.size > 0

        to_dir = ROOT_FOLDER/'evaluations'/year.to_s
        to_dir.mkdir_p

        Reporter.new(year: @year).each_report do |tuple, report|
          puts "Reporting for #{tuple.name} (#{year})"
          target = tuple.name.gsub(/\s+/, '_') + ".html"
          (to_dir/target).write report
        end
      end

    end # class Report
  end # class Command
end # module RQP2
