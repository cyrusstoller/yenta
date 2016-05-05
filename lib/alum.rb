class Alum
  attr_reader :id, :data
  attr_reader :match, :match_score
  
  @@new_id = 0

  def initialize(row)
    @id = (@@new_id += 1)
    @data = row
    @match = nil
    @match_score = 0
  end

  def add_match(student, score = nil)
    @match = student
    @match_score = score || ScoreService.compute(student, self)
  end

  def unmatch!
    @match = nil
    @match_score = 0
    self
  end
end
