require 'spec_helper'
module RQP2
  class DBMS
    describe Rel, 'execute_ddl' do

      let(:dbms){
        DBMS.for('tutorial-d')
      }

      after do
        dbms.execute_ddl("DROP VAR SUPPLIERS;")
        dbms.disconnect
      end

      subject do
        dbms.execute_ddl("VAR SUPPLIERS BASE RELATION {SID CHAR} KEY {SID};")
      end

      it 'should not raise an error' do
        ->{
          subject
        }.should_not raise_error
      end

    end
  end
end
