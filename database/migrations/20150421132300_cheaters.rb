Sequel.migration do
  up do
    run <<-SQL
      DROP VIEW IF EXISTS cheating_pairs CASCADE;

      CREATE OR REPLACE VIEW cheating_pairs AS
      WITH pairs AS (
        SELECT A1.puzzle,
               P1.level,
               A1.language   as language,
               A1.expression as expression,
               A1.answer     as answer1,
               A1.submission as submission1,
               S1.submission_year as year1,
               S1.student    as student1,
               A2.answer     as answer2,
               A2.submission as submission2,
               S2.submission_year as year2,
               S2.student    as student2
          FROM
            answers A1 JOIN answers A2
              ON  A1.puzzle = A2.puzzle
              AND A1.language = A2.language
              AND A1.expression = A2.expression
              AND A1.submission <> A2.submission
              AND A1.answer <> A2.answer
            JOIN submissions S1
              ON A1.submission = S1.submission
            JOIN submissions S2
              ON A2.submission = S2.submission
            JOIN puzzles P1
              ON A1.puzzle = P1.puzzle
          WHERE
              S1.student <> S2.student
          AND S1.submission_year = S2.submission_year
      )
      SELECT
        student1,
        year1,
        student2,
        year2,
        count(distinct answer1) AS "#answers"
      FROM pairs
      WHERE level>1
      GROUP BY student1, year1, student2, year2
      ;

      DROP VIEW IF EXISTS cheating_students CASCADE;

      CREATE OR REPLACE VIEW cheating_students AS
      SELECT
        student1 AS student,
        year1 AS year,
        SUM("#answers") AS "#answers",
        ( SELECT count(answer) FROM answers
          WHERE submission IN
            (SELECT submission FROM submissions WHERE student = P.student1 ) ) AS "#submitted",
        SUM("#answers")/( SELECT count(answer) FROM answers
          WHERE submission IN
            (SELECT submission FROM submissions WHERE student = P.student1 )
        ) AS cheat_ratio,
        ( SELECT score
          FROM submission_scoring
          WHERE submission IN (
            SELECT submission FROM submissions WHERE student = P.student1
          )
          LIMIT 1
        ) AS score,
        ( SELECT evaluation
          FROM submission_scoring
          WHERE submission IN (
            SELECT submission FROM submissions WHERE student = P.student1
          )
          LIMIT 1
        ) AS evaluation
      FROM cheating_pairs P
      GROUP BY student1, year1
      ORDER BY cheat_ratio DESC
      ;
    SQL
  end
end
