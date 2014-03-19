require 'spec_helper'
module RQP2
  class DBMS
    describe Rel, 'execute_dml' do

      let(:config) {
        RQP2.db_config_for("evaluator/rel")
      }

      let(:dbms){
        Rel.connect(config)
      }

      before do
        dbms.execute_ddl("VAR SUPPLIERS BASE RELATION {SID CHAR} KEY {SID};")
        dbms.execute_dml("INSERT SUPPLIERS RELATION{TUPLE{SID 'S1'}};")
      end

      after do
        dbms.execute_ddl("DROP VAR SUPPLIERS;")
        dbms.disconnect
      end

      subject do
        dbms.query("SUPPLIERS{SID}")
      end

      it 'should return the exepected relation' do
        subject.should eq(Relation(sid: "S1"))
      end

    end
  end
end
