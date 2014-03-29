module RQP2
  class Command
    # 
    # Check a student submission
    #
    # SYNOPSIS
    #   rqp2 import SUBMISSION_FILE
    #
    class Check < Quickl::Command(__FILE__, __LINE__)

      # Parse the options
      options do |opt|

        @queries = false
        opt.on('--queries', 'Check the queries agains a DBMS') do
          @queries = true
        end
      end

      # Command execution
      def execute(args)
        raise Quickl::ArgumentError unless args.size == 1
        file = Path(args.first)
        raise Quickl::ArgumentError unless file.exists?

        # First check with the validator
        Submission::XML::Validator.new.call(file)
        $stderr.puts "Submission is valid according to XSD schema."

        # Convert to data now
        check_queries(file) if @queries
      end

      def check_queries(file)
        dbmses = Hash.new{|h,k| h[k] = DBMS.for(k) }

        Submission.xml(file).to_data[:answers].each do |answer|
          answer = Tuple(answer)

          outcome = begin
            dbms = dbmses[answer.language]
            dbms.query(answer.expression)
            "ok"
          rescue => ex
            ex.message
          end
          puts "#{answer.puzzle}/#{answer.language}: #{outcome}"
        end
      ensure
        dbmses.each_value{|dbms| dbms.disconnect } if dbmses
      end

    end # class Check
  end # class Command
end # module RQP2
