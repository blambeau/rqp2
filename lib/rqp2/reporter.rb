module RQP2
  class Reporter

    attr_reader :db

    def initialize(focus = nil)
      @focus = focus || { year: Time.now.year.to_i }
    end
    attr_reader :focus

    def each_report
      reporting_data.each do |tuple|
        tuple = Tuple(tuple)
        report = Dialect.render(reporting_wlang, tuple)
        yield(tuple, report)
      end
    end

  private

    def reporting_wlang
      Path.dir/'reporter/report.html.wlang'
    end

    def reporting_data
      focus = self.focus
      db.relvar{
        scoring = allbut(answer_scoring, [:reference])
        answrs  = answers
        puzzls  = allbut(puzzles, [:exemplar, :hints])
        levels  = difficulty_levels
        subsco  = extend(submission_scoring, score: ->(t){ t.score.to_f.round(2) })
        subms   = join(allbut(submissions, :submitted_at), subsco)
        stus    = students
        bigjoin = join(join(stus, join(subms, join(answrs, join(puzzls, levels)))), scoring)

        bigjoin = restrict(bigjoin, focus) if focus

        details = allbut(answer_scoring_details, [:reference, :exemplar])
        details = group(details, [:answer], :details, allbut: true)
        details = extend(details, details: ->(t){ t.details.to_a(order: [:dataset]) })
        bigjoin = join(bigjoin, details)

        bigjoin = group(bigjoin,
          [ :submission, :student, :noma, :name, :email, :evaluation, :score, :grade,
            :puzzle, :difficulty, :level, :stars, :predicate, :description],
          :answers, allbut: true)
        bigjoin = extend(bigjoin,
          answers: ->(t){
            t.answers.to_a(order: [:position])
          },
          earned_stars: ->(t){
            t.answers.sum(:earned_stars)
          })
        bigjoin = extend(bigjoin, status: ->(t){
          if t.earned_stars.to_f == 0.0
            "failure"
          elsif t.earned_stars.to_f == t.stars.to_f
            "success"
          else
            "partial"
          end
        })

        bigjoin = group(bigjoin,
          [ :submission, :student, :noma, :name, :email, :evaluation, :score, :grade, ], :puzzles, allbut: true)
        bigjoin = extend(bigjoin, puzzles: ->(t){ t.puzzles.to_a(order: [:level, :puzzle])})
      }
    ensure
      disconnect
    end

    def db
      @db ||= RQP2::ALF_DATABASE.connection
    end

    def disconnect
      @db.close if @db
    end

  end # class Reporter
end # module RQP2
require_relative 'reporter/dialect'
