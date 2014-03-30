Sequel.migration do
  up do
    run <<-SQL
      CREATE VIEW answer_scoring_details AS
        WITH accounted_answers AS (
          SELECT * FROM answers AS A1
          WHERE NOT EXISTS (
            SELECT * FROM answers AS A2
            WHERE A2.submission=A1.submission
              AND A2.puzzle=A1.puzzle
              AND A2.language=A1.language
              AND A2.position>A1.position
          )
        )
        SELECT T.answer2 as answer,
               T.answer1 as reference,
               T.exemplar,
               T.dataset,
               T.outcome,
               T.details,
               CASE WHEN T.outcome='equivalent'
                    THEN 1
                    ELSE 0 
               END AS success,
               CASE WHEN A.answer IS NULL
                    THEN 0
                    ELSE 1
               END AS accounted
        FROM tests AS T
        LEFT JOIN accounted_answers as A ON T.answer2 = A.answer;
          
        CREATE VIEW answer_scoring AS
          WITH
          ds_summary AS (
            SELECT T.answer,
                   T.reference,
                   min(success)   AS success,
                   min(accounted) AS accounted
              FROM answer_scoring_details AS T
              GROUP BY T.answer, T.reference
          ),
          answer_and_stars AS (
            SELECT A.answer,
                   D.stars
              FROM answers AS A
              JOIN puzzles AS P ON A.puzzle = P.puzzle
              JOIN difficulty_levels AS D ON P.level = D.level
          )
          SELECT T.answer,
                 T.reference,
                 T.success,
                 T.accounted,
                 (D.stars * T.success * T.accounted)/2.0 AS earned_stars
          FROM ds_summary as T
          JOIN answer_and_stars AS D on D.answer = T.answer;

        CREATE VIEW submission_scoring AS
          WITH scoring AS (
            SELECT A.submission,
                   sum(SC.earned_stars) AS score
              FROM answer_scoring AS SC
              JOIN answers        AS A ON A.answer = SC.answer
              GROUP BY A.submission
          )
          SELECT S.submission,
                 S.score,
                 G.evaluation,
                 G.grade
          FROM scoring AS S, grades AS G
          WHERE S.score >= G.score
          AND NOT EXISTS (
            SELECT * FROM grades G2
            WHERE G2.score > G.score
              AND S.score >= G2.score
          )
          ORDER BY S.score desc
    SQL
  end
  down do
    run <<-SQL
      DROP VIEW submission_scoring;
      DROP VIEW answer_scoring;
      DROP VIEW answer_scoring_details;
    SQL
  end
end