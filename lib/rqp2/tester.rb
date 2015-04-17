module RQP2
  class Tester

    attr_reader :db, :my_submission, :tests, :dbmses, :against

    def initialize(against)
      @dbmses  = Hash.new{|h,k| h[k] = RQP2::DBMS.for(k) }
      @against = against
    end

    def db
      @db ||= RQP2::ALF_DATABASE.connection
    end

    def disconnect
      @db.close if @db
      @dbmses.each_value{|dbms| dbms.disconnect } if @dbmses
    end

    def my_submission
      against = self.against
      @my_submission ||= db.tuple_extract{
        me            = restrict(students, against)
        my_submission = matching(submissions, project(me, [:student]))
      }[:submission]
    end

    def tests
      sub = my_submission
      @tests ||= db.relvar{
        pred  = Alf::Predicate.eq(:submission1, sub)
        pred &= Alf::Predicate.eq(:language1, :language2)
        pred &= Alf::Predicate.neq(:language1, 'alf')
        rename(restrict(pending_tests, pred), :language1 => :language)
      }.to_a(order: [:language, :exemplar, :dataset])
    end

    def call
      tests    = self.tests
      language = nil
      dataset  = nil
      dbms     = nil
      tests.each_with_index do |test, index|
        test          = Tuple(test)
        test_language = test.project([:language])
        test_exemplar = test.project([:exemplar, :language])
        test_dataset  = test.project([:exemplar, :dataset, :language])

        # ensure the dbms is ok
        unless language == test_language
          language = test_language
          dataset  = nil
          dbms     = dbmses[language.language]

          install_exemplar_on(test_exemplar, dbms)
        end

        # ensure the dataset is ok
        unless dataset == test_dataset
          dataset = test_dataset

          install_dataset_on(dataset, dbms)
        end

        result = test.project([:answer1, :answer2, :exemplar, :dataset])
                     .extend(execute_test_on(test, dbms))

        if result[:outcome] == 'failure'
          puts test.expression1
          raise "Failure: " + result[:details]
        elsif result[:outcome] == 'error'
          puts test.expression2
          raise "Error: " + result[:details]
        end
        db.relvar(:tests).insert(result)

        puts "#{index}/#{tests.size}: #{result.inspect}"
      end
    ensure
      disconnect
    end

    def execute_test_on(test, dbms)
      # Take the one at left or fail
      begin
        rel1 = dbms.query(test.expression1)
      rescue => ex
        puts test.inspect
        return { outcome: "failure", details: ex.message }
      end

      # Take the one at right or error
      begin
        rel2 = dbms.query(test.expression2)
      rescue => ex
        return { outcome: "parsing error", details: ex.message }
      end

      if not(rel1.empty? || rel2.empty?) && rel1.heading != rel2.heading
        { outcome: "heading mismatch",
          details: "    #{rel1.heading}\nvs. #{rel2.heading}" }
      elsif rel1 != rel2
        { outcome: "not equivalent",
          details: Relation(expected: rel1, got: rel2).to_text }
      else
        { outcome: "equivalent",
          details: 'good job!' }
      end

    rescue => ex
      return { outcome: "error", details: ex.message }
    end

  private

    def install_exemplar_on(schema, dbms)
      puts "Installing schema `#{schema}`"

      s = db.tuple_extract{ restrict(schemas, schema) }
      dbms.execute_ddl(s.formaldef) rescue nil
    end

    def install_dataset_on(dataset, dbms)
      puts "Changing dataset to `#{dataset}`"

      ds = db.tuple_extract{ restrict(datadefs, dataset) }
      dbms.execute_dml(ds.formaldef)
    end

  end # module Tester
end # module RQP2
