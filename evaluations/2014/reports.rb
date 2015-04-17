require 'rqp2'
require 'wlang'

class Dialect < WLang::Html

  def floating(buf, fn)
    value = evaluate(render(fn))
    buf << ((value.to_i == value) ? value.to_i : value.to_f).to_s
  end

  def classes(buf, fn)
    value   = evaluate(render(fn))
    classes = []
    classes << 'success' if value[:success]   == 1
    classes << 'failure' if value[:success]   == 0
    classes << 'ignored' if value[:accounted] == 0
    buf << classes.join(' ')
  end

  tag '@', :classes
  tag '.', :floating

end

class Reports

  attr_reader :db

  def initialize
  end

  def db
    @db ||= RQP2::ALF_DATABASE.connection
  end

  def disconnect
    @db.close if @db
  end

  def call
    rv = db.relvar{
      scoring = allbut(answer_scoring, [:reference])
      answrs  = answers
      puzzls  = allbut(puzzles, [:exemplar, :hints])
      levels  = difficulty_levels
      subsco  = extend(submission_scoring, score: ->(t){ t.score.to_f.round(2) })
      subms   = join(allbut(submissions, :submitted_at), subsco)
      stus    = students
      bigjoin = join(join(stus, join(subms, join(answrs, join(puzzls, levels)))), scoring)

      details = allbut(answer_scoring_details, [:reference, :exemplar])
      details = group(details, [:answer], :details, allbut: true)
      details = extend(details, details: ->(t){ t.details.to_a(order: [:dataset]) })
      bigjoin = join(bigjoin, details)

      bigjoin = group(bigjoin,
        [ :submission, :student, :noma, :name, :evaluation, :score, :grade,
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
        [ :submission, :student, :noma, :name, :evaluation, :score, :grade, ], :puzzles, allbut: true)
      bigjoin = extend(bigjoin, puzzles: ->(t){ t.puzzles.to_a(order: [:level, :puzzle])})
    }
  ensure
    disconnect
  end

end

data = Reports.new.call #.restrict(submission: 'd2db6b40-9996-0131-54f9-3c07545ed162')
data.each do |tuple|
  tuple = Tuple(tuple)
  puts "Reporting for #{tuple.name}"
  target = tuple.name.gsub(/\s+/, '_') + ".html"
  report = Dialect.render(Path.dir/'report.wlang', tuple)
  (Path.dir/target).write report
end