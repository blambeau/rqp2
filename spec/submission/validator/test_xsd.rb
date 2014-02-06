require 'spec_helper'
module RQP2
  module Submission
    describe Validator, ".xsd" do

      subject{ Validator.xsd }

      it 'does not raise an error' do
        ->{
          subject
        }.should_not raise_error
      end

      it 'returns a nokogiri validator' do
        subject.should be_a(Nokogiri::XML::Schema)
      end

    end # describe Validator
  end # module Submission
end # module RQP2
