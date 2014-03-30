Sequel.migration do
  up do

    run <<-SQL
      CREATE TABLE tests (
        answer1   CHAR(36)     NOT NULL REFERENCES answers (answer),
        answer2   CHAR(36)     NOT NULL REFERENCES answers (answer),
        exemplar  VARCHAR(30)  NOT NULL,
        dataset   VARCHAR(20)  NOT NULL,
        outcome   VARCHAR(20)  NOT NULL,
        details   TEXT         NOT NULL DEFAULT '',
        PRIMARY KEY (answer1, answer2, exemplar, dataset),
        FOREIGN KEY (exemplar, dataset) REFERENCES datasets (exemplar, dataset)
      );
      CREATE FUNCTION remove_tests_matching_answer() RETURNS trigger AS $s$
        BEGIN
          DELETE FROM tests WHERE answer1 = OLD.answer OR answer2 = OLD.answer;
          RETURN NEW;
        END;
      $s$ LANGUAGE plpgsql;
      CREATE TRIGGER trg_remove_tests_on_answer_update
        AFTER UPDATE ON answers
        FOR EACH ROW EXECUTE PROCEDURE remove_tests_matching_answer();
    SQL

    run <<-SQL
      CREATE VIEW test_candidates AS
        SELECT A.puzzle,
               P.exemplar,
               D.dataset,
               A.answer1,
               A.submission1,
               A.language1,
               A.expression1,
               A.answer2,
               A.submission2,
               A.language2,
               A.expression2
          FROM answer_pairs A
          JOIN puzzles  P ON A.puzzle   = P.puzzle
          JOIN datasets D ON P.exemplar = D.exemplar
    SQL

    run <<-SQL
      CREATE VIEW pending_tests AS
        SELECT * FROM test_candidates AS C
        WHERE NOT EXISTS (
          SELECT * FROM tests AS T
          WHERE C.answer1  = T.answer1
            AND C.answer2  = T.answer2
            AND C.exemplar = T.exemplar
            AND C.dataset  = T.dataset)
    SQL
  end
  down do
    run <<-SQL
      DROP VIEW pending_tests;
      DROP VIEW test_candidates;
      DROP FUNCTION remove_tests_matching_answer cascase CASCADE;
      DROP TABLE tests;
    SQL
  end
end
