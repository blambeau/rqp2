require_relative 'dbms/sql'
require_relative 'dbms/rel'
module RQP2
  class DBMS

    DBMS_CLASSES = [ RQP2::DBMS::SQL, RQP2::DBMS::Rel ]

    def self.for(language, config = nil)
      config ||= RQP2.db_config_for("languages/#{language}")
      DBMS_CLASSES.find{|d| d.language == language }.connect(config)
    end

    def self.postgres(connspec)
      SQL.new(connspec)
    end

    def self.rel(connspec)
      Rel.new(connspec)
    end

  end # class DBMS
end # module RQP2
