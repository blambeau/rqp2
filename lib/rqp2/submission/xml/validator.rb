module RQP2
  class Submission
    module XML
      class Validator
        include XML::Support

        ValidationError = Class.new(StandardError)

        SUBMISSION_SCHEMA_FILE = RQP2::ASSETS_FOLDER/"submission-schema.xsd"

        # Validates `submission` against the schema, yielding the block
        # with every error found.
        #
        # If no block is provided, raises a ValidationError on the first
        # error encountered, with that error as message.
        #
        # Returns true if ok, false if at least one error.
        def call(submission, &on_error)
          on_error ||= ->(err){ raise ValidationError, err }
          submission = xmldoc_for(submission)
          errors = self.class.xsd.validate(submission)
          errors.each(&on_error)
          errors.empty?
        end

      private

        # Lazy loading of the XSL nokogiri validator
        def self.xsd
          @xsd ||= Nokogiri::XML::Schema(SUBMISSION_SCHEMA_FILE)
        end

      end # class Validator
    end # module XML
  end # class Submission
end # module RQP2
