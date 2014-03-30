Sequel.migration do
  up do
    run <<-SQL
      CREATE INDEX idx_answers_puzzle ON answers (puzzle);
      CREATE VIEW answer_pairs AS
        SELECT A1.puzzle,
               A1.answer     as answer1,
               A1.submission as submission1,
               A1.language   as language1,
               A1.expression as expression1,
               A2.answer     as answer2,
               A2.submission as submission2,
               A2.language   as language2,
               A2.expression as expression2
          FROM answers A1, answers A2
          WHERE A1.puzzle  = A2.puzzle
            AND A1.answer != A2.answer
    SQL
  end
  down do
    run <<-SQL
      DROP INDEX idx_answers_puzzle;
      DROP VIEW answer_pairs;
    SQL
  end
end
