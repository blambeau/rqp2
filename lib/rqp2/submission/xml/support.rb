module RQP2
  class Submission
    module XML
      module Support

        def xmldoc_for(arg)
          return arg if arg.kind_of?(Nokogiri::XML::Document)
          Nokogiri::XML(arg)
        end

        extend self
      end # module Support
    end # module XML
  end # class Submission
end # module RQP2
