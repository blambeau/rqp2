Sequel.migration do
  up do
    run <<-SQL
      CREATE TABLE students (
        student    CHAR(36)     NOT NULL PRIMARY KEY,
        noma       CHAR(10)     NOT NULL UNIQUE,
        name       VARCHAR(255) NOT NULL CHECK (name <> '')
      );
      CREATE TABLE puzzles (
        puzzle      VARCHAR(5)  NOT NULL PRIMARY KEY,
        stars       INTEGER     NOT NULL CHECK (stars > 0),
        difficulty  VARCHAR(20) NOT NULL CHECK (difficulty <> ''),
        predicate   TEXT        NOT NULL CHECK (predicate <> ''),
        description TEXT        NOT NULL CHECK (description <> ''),
        hints       TEXT        NOT NULL
      );
      CREATE TABLE languages (
        language    VARCHAR(20)  NOT NULL CHECK (language <> '') PRIMARY KEY,
        name        VARCHAR(255) NOT NULL CHECK (name <> '') 
      );
      CREATE TABLE submissions (
        submission    CHAR(36) NOT NULL PRIMARY KEY,
        student       CHAR(36) NOT NULL REFERENCES students (student),
        submitted_at TIME WITHOUT TIME ZONE NOT NULL
      );
      CREATE TABLE answers (
        answer        CHAR(36)    NOT NULL PRIMARY KEY,
        submission    CHAR(36)    NOT NULL REFERENCES submissions (submission),
        puzzle        VARCHAR(5)  NOT NULL REFERENCES puzzles (puzzle),
        language      VARCHAR(20) NOT NULL REFERENCES languages (language),
        position      INTEGER     NOT NULL CHECK (position >= 0),
        expression    TEXT        NOT NULL CHECK (expression <> '')
      );
    SQL
  end
  down do
    run <<-SQL
      DROP TABLE languages;
      DROP TABLE puzzles;
      DROP TABLE students;
    SQL
  end
end
