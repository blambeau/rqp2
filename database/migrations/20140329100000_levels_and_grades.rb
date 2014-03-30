Sequel.migration do
  up do
    run <<-SQL
      CREATE TABLE difficulty_levels (
        level       INTEGER      NOT NULL PRIMARY KEY CHECK (level >= 0),
        difficulty  VARCHAR(20)  NOT NULL CHECK (difficulty <> '') UNIQUE,
        stars       INTEGER      NOT NULL CHECK (stars > 0)
      );

      INSERT INTO difficulty_levels
        SELECT DISTINCT cast(log(2, stars) AS INTEGER) AS level,
                        difficulty,
                        stars
        FROM puzzles
        ORDER BY stars;

      ALTER TABLE puzzles
        ADD COLUMN level INTEGER NOT NULL DEFAULT 0 REFERENCES difficulty_levels (level);
      UPDATE puzzles P
        SET level = (SELECT level FROM difficulty_levels WHERE difficulty = P.difficulty);
      ALTER TABLE puzzles
        DROP COLUMN difficulty;
      ALTER TABLE puzzles
        DROP COLUMN stars;

      CREATE TABLE grades (
        score       INTEGER      NOT NULL PRIMARY KEY CHECK (score > 0),
        evaluation  VARCHAR(20)  NOT NULL CHECK (evaluation <> '') UNIQUE,
        grade       INTEGER      NOT NULL CHECK (grade >= 0 and grade <= 20) UNIQUE
      );
    SQL
  end
end
