class Student
  attr_reader :id, :data, :preferences
  attr_reader :match, :match_score
  
  @@new_id = 0

  def initialize(row)
    @id = (@@new_id += 1)
    @data = row    
    @preferences = []
    @match = nil
    @match_score = 0
  end

  def add_candidates(alums)
    alums.each do |alum|
      @preferences << [alum, compute_score(alum)]
    end
    sort_preferences
  end

  def add_match(alum, score = nil)
    @match = alum
    @match_score = score || ScoreService.compute(self, alum)

    # Setting vars on the alum
    @match.add_match(self, @match_score)
  end

  def unmatch!
    @match = nil
    @match_score = 0
    self
  end

  def compute_score(alum)
    ScoreService.compute(self, alum) 
  end

  def self.current_id
    @@new_id
  end

  private

  def sort_preferences
    @preferences.sort! { |a,b| a[1] <=> b[1] }
  end
end
