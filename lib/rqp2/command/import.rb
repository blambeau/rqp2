module RQP2
  class Command
    # 
    # Import some student submissions
    #
    # SYNOPSIS
    #   rqp2 import SUBMISSION_FILE...
    #
    class Import < Quickl::Command(__FILE__, __LINE__)

      attr_reader :conn
      attr_reader :student
      attr_reader :submission
      attr_reader :answers

      # Parse the options
      options do |opt|
      end

      # Command execution
      def execute(args)
        ALF_DATABASE.connect do |conn|
          @conn = conn
          args.each do |file|
            file = Path(file)
            conn.in_transaction do
              import_submission_file(file)
            end
          end
        end
      end

    private

      def import_submission_file(file)
        data        = Submission.xml(file).to_data
        @student    = import_student(data[:student])
        @submission = import_submission(data)
        @answers    = import_answers(data[:answers])
      end

      # Imports a new student and returns the corresponding UUID
      def import_student(student)
        student.merge(student: UUID.generate).tap do |tuple|
          conn.relvar(:students).insert(tuple)
        end
      end

      def import_submission(submission)
        { 
          submission: UUID.generate,
          student: student[:student],
          submitted_at: Time.now
        }.tap do |tuple|
          conn.relvar(:submissions).insert(tuple)
        end
      end

      def import_answers(answers)
        answers = Relation(answers).extend(
          answer: ->{ UUID.generate },
          submission: submission[:submission]
        )
        conn.relvar(:answers).insert(answers)
      end

    end # class Import
  end # class Command
end # module RQP2