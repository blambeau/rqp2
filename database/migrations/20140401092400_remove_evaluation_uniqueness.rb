Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE grades DROP CONSTRAINT grades_evaluation_key;
      ALTER TABLE grades DROP CONSTRAINT grades_grade_key;
    SQL
  end
end
