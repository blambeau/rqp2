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
        @focus = { submission_year: Time.now.year }
        @send_email = false
      end
      attr_reader :focus

      def send_email?
        !!@send_email
      end

      # Parse the options
      options do |opt|
        opt.on('--year=YEAR') do |year|
          focus[:submission_year] = Integer(year)
        end
        opt.on('--submission=UUID') do |uuid|
          focus[:submission] = uuid
        end
        opt.on('--send-email') do
          @send_email = true
        end
        opt.on('--bypass=FILE') do |bypass|
          @bypass = Path(bypass).read
        end
      end

      # Command execution
      def execute(args)
        raise Quickl::InvalidArgument if args.size > 0

        to_dir = ROOT_FOLDER/'evaluations'/focus[:submission_year].to_s
        to_dir.mkdir_p

        Reporter.new(focus).each_report do |tuple, report|
          handle_report(tuple, report, to_dir)
        end
      end

      def handle_report(tuple, report, to_dir)
        if bypass?(tuple)
          puts "Bypassing #{tuple.name} (#{tuple.email})"
          return
        end

        puts "Reporting for #{tuple.name} (#{tuple.email}) in #{to_dir}"

        # write it to a file
        target = tuple.name.gsub(/\s+/, '_') + ".html"
        target = to_dir/target
        target.write report

        # send an email if required
        send_email(tuple, target) if send_email?
      end

      def send_email(tuple, target)
        puts "Sending report to #{tuple.email}"

        mail = Mail.new do
          from     MAIL_CONFIG["from"]
          to       tuple.email.to_s
          cc       (MAIL_CONFIG["replyto"] || MAIL_CONFIG["from"])
          reply_to (MAIL_CONFIG["replyto"] || MAIL_CONFIG["from"])
          subject  "[INGI2172] submission feedback for Mission 2"
          html_part do
            content_type 'text/html; charset=UTF-8'
            body WLang::Html.render(Path.dir/'report.email', 
              { 
                signature: (MAIL_CONFIG["emailsignature"] || "The TAs"), 
                name: tuple.name
              })
          end
          add_file target.to_s
        end

        mail.deliver!
      end

      def bypass?(tuple)
        @bypass && @bypass.include?(tuple.email)
      end

    end # class Report
  end # class Command
end # module RQP2
