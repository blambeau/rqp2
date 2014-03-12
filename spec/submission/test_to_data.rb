require 'spec_helper'
module RQP2
  describe Submission, "to_data" do

    let(:sub){
      Submission.xml(FIXTURES/"submissions/right/multiple-answer-per-puzzle.xml")
    }

    subject{
      sub.to_data
    }

    let(:expected){
      {
        student: {
          name: "Bernard Lambeau",
          noma: "0110-14-52"
        },
        answers: [
          {
            puzzle: "E1",
            language: "sql",
            expression: "SELECT p.pid FROM parts AS p",
            position: 0
          },
          {
            puzzle: "E1",
            language: "tutorial-d",
            expression: "PARTS",
            position: 1
          },
          {
            puzzle: "E1",
            language: "tutorial-d",
            expression: "PARTS{PID}",
            position: 2
          }
        ]
      }
    }

    it{ should eq(expected) }

    it 'should be a valid submission according to the Q schema' do
      type = Qrb.parse(ASSETS/"submission.q")["Submission"]
      ->{
        type.dress(subject)
      }.should_not raise_error
    end

  end
end
