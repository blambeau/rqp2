require 'spec_helper'
module RQP2
  class DBMS
    describe SQL, 'execute_dml' do

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
      end

      after do
        dbms.execute_ddl("DROP TABLE IF EXISTS suppliers;")
        dbms.disconnect
      end

      subject do
        dbms.execute_dml('INSERT INTO suppliers VALUES (12)');
      end

      it 'should not raise an error' do
        ->{
          subject
        }.should_not raise_error
      end

    end
  end
end
