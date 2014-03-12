require_relative 'submission/xml'
module RQP2
  class Submission

    def initialize(data)
      @data = data
    end

    # Load a submission from a XML file
    def self.xml(file)
      new XML::Reader.new(file).to_data
    end

    # Returns pure data from this submission according to our Q schema.
    def to_data
      @data
    end

  end # class Submission
end # module RQP2
