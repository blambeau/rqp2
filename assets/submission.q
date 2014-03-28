Name       = <as> .String
Noma       = <as> .String( s | s =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ )
PuzzleId   = <as> .String( s | s =~ /^[SEMDH]\d+$/ )
LangId     = <as> .String( s | %w{alf sql tutorial-d}.include? s )
Expression = <as> .String
Posint     = .Integer( i | i >= 0 )

# Information about a student
Student = <data> {
  noma: Noma,
  name: Name
}

# Information about an answer
Answer = <data> {
  puzzle:     PuzzleId,
  language:   LangId,
  position:   Posint,
  expression: Expression
}

# Information about submission
Submission = <data> {
  student: Student,
  answers: [Answer]
}
