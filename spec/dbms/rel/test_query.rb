require 'spec_helper'
module RQP2
  class DBMS
    describe Rel, 'execute_dml' do

      let(:dbms){
        DBMS.for('tutorial-d')
      }

      before do
        dbms.execute_ddl("VAR SUPPLIERS BASE RELATION {SID CHAR} KEY {SID};")
        dbms.execute_dml("INSERT SUPPLIERS RELATION{TUPLE{SID 'S1'}};")
      end

      after do
        dbms.execute_ddl("DROP VAR SUPPLIERS;")
        dbms.disconnect
      end

      context 'when the result is not empty' do
        subject do
          dbms.query("SUPPLIERS{SID}")
        end

        it 'should return the exepected relation' do
          subject.should eq(Relation(sid: "S1"))
        end
      end

      context 'when the result is empty' do
        subject do
          dbms.query("SUPPLIERS WHERE SID=''")
        end

        it 'should return the exepected relation' do
          subject.should be_empty
        end
      end

    end
  end
end
