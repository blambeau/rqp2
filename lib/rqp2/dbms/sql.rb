module RQP2
  class DBMS
    class SQL < self

      def initialize(sequel_db)
        @sequel_db = sequel_db
      end

      def self.connect(connspec)
        unless connspec.is_a?(Sequel::Database)
          connspec = ::Sequel.connect(connspec)
        end
        SQL.new(connspec)
      end

      def disconnect
        @sequel_db.disconnect
      end

      def execute_ddl(ddl)
        @sequel_db.execute_ddl(ddl)
      end

      def execute_dml(dml)
        @sequel_db.execute_dui(dml)
      end

      def query(src)
        Alf::Relation(@sequel_db[src])
      end

    end # class SQL
  end # class DBMS
end # module RQP2
