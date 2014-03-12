require 'spec_helper'
module RQP2
  class Submission
    module XML
      describe Validator, "#call" do

        WRONG = (FIXTURES/"submissions/wrong").glob("*.xml")

        RIGHT = (FIXTURES/"submissions/right").glob("*.xml")

        context 'with a block' do

          it 'yields the block with error messages' do
            seen = nil
            Validator.new.call(WRONG.first) do |err|
              seen = err
            end
            seen.should_not be_nil
          end

          it 'returns true if ok' do
            Validator.new.call(RIGHT.first){|err| }.should be_true
          end

          it 'return false on error' do
            Validator.new.call(WRONG.first){|err| }.should be_false
          end
        end

        context 'without block' do

          WRONG.each do |file|
            it "should raise an error on `#{file.basename}`" do
              ->{
                Validator.new.call(file)
              }.should raise_error(Validator::ValidationError)
            end
          end

          RIGHT.each do |file|
            it "should not raise an error on `#{file.basename}`" do
              Validator.new.call(file).should be_true
            end
          end

        end # without block

      end # describe Validator
    end # module XML
  end # class Submission
end # module RQP2
