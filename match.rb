require 'csv'

require_relative "student.rb"
require_relative "alum.rb"
require_relative "score_service.rb"

def main
  announce "Parsing Alums..."
  alums = parse_alums

  announce "Parsing Students..."
  students = parse_students

  announce "Splitting RCs and ECs"
  ecs = students.select { |s| s.data["Class Year"] =~ /EC/ }
  rcs = students - ecs
  
  announce "Starting Gale Shapley for ECs"
  preprocess(ecs, alums)
  matched_students = gale_shapley(ecs, alums)

  announce "Starting Gale Shapley for RCs"
  remaining_alums = alums.select { |a| a.match.nil? }
  preprocess(rcs, remaining_alums)
  matched_students = gale_shapley(rcs, remaining_alums)

  output_file("output.csv", students, alums)

  announce "Alums who didn't get matched"
  p alums.reject { |a| not a.match.nil? }.map { |a| a.data["Email Address"] }.uniq
end

def parse_alums
  alums = []
  CSV.parse(File.read("data/alumni.csv"), :headers => true).each do |row|
    case row["How many students are you willing to mentor?"]
    when "One"
      num = 1
    when "Two"
      num = 2
    when "Three"
      num = 3
    else
      num = 1
    end

    num.times do
      alums << Alum.new(row)
    end
  end
  alums
end

def parse_students
  students = []
  CSV.parse(File.read("data/students.csv"), :headers => true).each do |row|
    students << Student.new(row)
  end
  students
end

def preprocess(students, alums)
  students.each do |student|
    if student.id % 50 == 0
      puts "Processing Student id: #{student.id}"
    end
    student.add_candidates(alums)
  end
end

def gale_shapley(students, alums)
  # Implementation of https://en.wikipedia.org/wiki/Stable_marriage_problem
  #
  # function stableMatching {
  #     Initialize all m ∈ M and w ∈ W to free
  #     while ∃ free man m who still has a woman w to propose to {
  #        w = first woman on m’s list to whom m has not yet proposed
  #        if w is free
  #          (m, w) become engaged
  #        else some pair (m', w) already exists
  #          if w prefers m to m'
  #             m' becomes free
  #            (m, w) become engaged 
  #          else
  #            (m', w) remain engaged
  #     }
  # }

  free_students, free_alums = students.dup, alums.dup
  max_iterations = 10000 * free_students.length

  while free_students.length > 0 && max_iterations > 0
    student = free_students.pop
    preferred_alum, score = student.preferences.pop

    if max_iterations % 100 == 0
      puts "iter_remaining: #{max_iterations} / remaining_students: #{free_students.length}" + \
        " / remaining alums: #{free_alums.length} " + \
        "Student id: #{student.id} - Alum id:#{preferred_alum.id} - Score: #{score}"
    end

    if free_alums.delete(preferred_alum)
      # Alum was free
      student.add_match(preferred_alum, score)
    else
      # Alum was already taken
      if preferred_alum.match_score < score
        # Alum prefers new student to old student
        old_match = preferred_alum.match.unmatch! rescue nil
        student.add_match(preferred_alum, score)

        # Make it so that we check everyone else first
        free_students.insert(0, old_match) unless old_match.nil?
      else
        free_students.insert(0, student)
      end
    end

    # To stop this from running forever
    max_iterations -= 1
  end

  matched_students = students.reject { |s| s.match.nil? }
end

def announce(str)
  output = %(
****************************************
#{str}
****************************************
  )
  puts output
end

def output_file(filename, students, alums)
  f = File.open(filename, "w")

  # Write headers
  str = (["score"] + alums.first.data.headers + students.first.data.headers).to_csv
  f.write(str)
  f.flush

  # Cycling through alums b/c there were more alums than students
  alums.sort { |a,b| a.match_score <=> b.match_score }.each do |alum|
    student = alum.match
    student_fields = student.data.fields rescue []
    str = ([alum.match_score] + alum.data.fields + student_fields).to_csv
    f.write(str)
    f.flush
  end

  f.close
end

if __FILE__ == $PROGRAM_NAME
  main
end
