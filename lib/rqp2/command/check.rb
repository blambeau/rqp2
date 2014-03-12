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
        puts Submission.xml(file).to_data.inspect
      end

    end # class Check
  end # class Command
end # module RQP2
