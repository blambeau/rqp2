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
        @send_email = false
      end
      attr_reader :year

      def send_email?
        !!@send_email
      end

      # Parse the options
      options do |opt|
        opt.on('--year=YEAR') do |year|
          @year = Integer(year)
        end
        opt.on('--send-email') do
          @send_email = true
        end
      end

      # Command execution
      def execute(args)
        raise Quickl::InvalidArgument if args.size > 0

        to_dir = ROOT_FOLDER/'evaluations'/year.to_s
        to_dir.mkdir_p

        Reporter.new(year: @year).each_report do |tuple, report|
          puts "Reporting for #{tuple.name} (#{year})"

          # write it to a file
          target = tuple.name.gsub(/\s+/, '_') + ".html"
          target = to_dir/target
          target.write report

          # send an email if required
          send_email(tuple, target) if send_email?
        end
      end

      def send_email(tuple, target)
        puts "Sending report to #{tuple.email}"

        Mail.deliver do
          from    'blambeau@gmail.com'
          to      tuple.email.to_s
          cc      'bernard.lambeau@uclouvain.be'
          subject "[INGI2172] submission feedback for Mission 2"
          html_part do
            content_type 'text/html; charset=UTF-8'
            body WLang::Html.render(Path.dir/'report.email', {})
          end
          add_file target.to_s
        end
      end

    end # class Report
  end # class Command
end # module RQP2
