module RQP2
  class Submission
    module XML
      module Support

        def xmldoc_for(arg)
          return arg if arg.kind_of?(Nokogiri::XML::Document)
          return xmldoc_for(Path(arg).read) if arg.is_a?(Path)
          Nokogiri::XML(arg)
        end

        extend self
      end # module Support
    end # module XML
  end # class Submission
end # module RQP2
