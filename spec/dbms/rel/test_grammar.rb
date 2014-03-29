require 'spec_helper'
module RQP2
  class DBMS
    describe Rel::Grammar do

      (Path.dir/'grammar').glob("*.rel") do |file|
        describe file.basename do

          it 'should compile it without failure' do
            Rel::Grammar.parse(file.read).value
          end
        end
      end

    end
  end
end

