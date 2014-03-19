Sequel.migration do
  up do
    run <<-SQL
      CREATE TABLE exemplars (
        exemplar    VARCHAR(30)  NOT NULL CHECK (exemplar <> '') PRIMARY KEY,
        name        VARCHAR(255) NOT NULL CHECK (name <> '') UNIQUE,
        description TEXT NOT NULL
      );
      CREATE TABLE schemas (
        exemplar VARCHAR(30) NOT NULL REFERENCES exemplars (exemplar),
        language VARCHAR(20) NOT NULL REFERENCES languages (language),
        formaldef TEXT NOT NULL,
        PRIMARY KEY (exemplar, language)
      );
      CREATE TABLE datasets (
        exemplar    VARCHAR(30) NOT NULL REFERENCES exemplars (exemplar),
        dataset     VARCHAR(20) NOT NULL CHECK (dataset <> ''),
        description TEXT NOT NULL,
        PRIMARY KEY (exemplar, dataset)
      );
      CREATE TABLE datadefs (
        exemplar VARCHAR(30) NOT NULL,
        dataset  VARCHAR(20) NOT NULL,
        language VARCHAR(20) NOT NULL REFERENCES languages (language),
        formaldef TEXT NOT NULL,
        PRIMARY KEY (exemplar, dataset, language),
        FOREIGN KEY (exemplar, dataset) REFERENCES datasets (exemplar, dataset)
      );
    SQL
  end
  down do
    run <<-SQL
      DROP TABLE datasets;
      DROP TABLE schemas;
      DROP TABLE exemplars;
    SQL
  end
end
