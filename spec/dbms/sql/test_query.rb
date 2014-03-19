require 'spec_helper'
module RQP2
  class DBMS
    describe SQL, 'query' do

      let(:config) {
        RQP2.db_config_for("evaluator/sql")
      }

      let(:sequel_db) {
        ::Sequel.connect(config)
      }

      let(:dbms){
        SQL.connect(sequel_db)
      }

      before do
        dbms.execute_ddl("CREATE TABLE suppliers (sid SERIAL PRIMARY KEY);")
        dbms.execute_dml('INSERT INTO suppliers VALUES (12)');
      end

      after do
        dbms.execute_ddl("DROP TABLE IF EXISTS suppliers;")
        dbms.disconnect
      end

      subject do
        dbms.query("SELECT sid FROM suppliers")
      end

      it 'should return the exepected relation' do
        subject.should eq(Relation(sid: 12))
      end

    end
  end
end
