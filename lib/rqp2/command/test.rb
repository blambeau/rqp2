module RQP2
  class Command
    #
    # Test student submissions against a reference one
    #
    # SYNOPSIS
    #   rqp2 [options] test
    #
    class Test < Quickl::Command(__FILE__, __LINE__)

      def initialize(*args)
        super
        @against = { name: 'Bernard Lambeau' }
      end
      attr_reader :against

      # Parse the options
      options do |opt|
      end

      # Command execution
      def execute(args)
        raise Quickl::InvalidArgument  if args.size > 0
        Tester.new(against).call
      end

    end # class Test
  end # class Command
end # module RQP2
