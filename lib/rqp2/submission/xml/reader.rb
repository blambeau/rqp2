module RQP2
  class Submission
    module XML
      class Reader
        include XML::Support

        def initialize(doc)
          @doc = XML::Support.xmldoc_for(doc)
        end
        attr_reader :doc

        def to_data
          # Check precondition that the file must be valid
          Validator.new.call(doc)

          {
            student: parse_student,
            answers: parse_answers
          }
        end

      private

        def parse_student
          {
            name: doc.xpath("//student/name").text,
            noma: doc.xpath("//student/noma").text,
          }
        end

        def parse_answers
          answers = []
          doc.xpath("//answers/puzzle").each do |puzzle|
            puzzle.xpath("answer").each_with_index do |answer, index|
              expression = strip(answer.text.to_s)
              answers << {
                puzzle:   puzzle['id'].to_s,
                language: answer['language'].to_s,
                expression: expression,
                position: index
              } unless expression.empty?
            end
          end
          answers
        end

        def strip(s)
          s = s.gsub(/\t/, '    ')
          if s =~ /\A[ ]*\n(\s+)/
            s.gsub(/^#{$1}/, '').strip
          else
            s
          end
        end

      end # class Reader
    end # module XML
  end # class Submission
end # module RQP2
