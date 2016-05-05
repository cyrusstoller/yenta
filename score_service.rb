class ScoreService
  PREF_WEIGHTS = [200,100,75,50,25,12,6,3,2]
  NO_OPINION_WEIGHT = 0.25
  NO_PREF_STRING = "[No Preference]"

  def self.compute(student, alum)
    sum = 0
    sum += industry(student, alum) * coefficient(student, "Priority [Industry]")
    sum += function(student, alum) * coefficient(student, "Priority [Function]")
    sum += geography(student, alum) * coefficient(student, "Priority [Geography]")
    sum += gender(student, alum) * coefficient(student, "Priority [Gender]")
    sum += race(student, alum) * coefficient(student, "Priority [Race]")
    sum += sexual_orientation(student, alum) * coefficient(student, "Priority [Sexual Orientation]")
    sum += military(student, alum) * coefficient(student, "Priority [Military]")
    sum += joint_degree(student, alum) * coefficient(student, "Priority [Joint Degree]")
    sum += family_business(student, alum) * coefficient(student, "Priority [Family Business]")
  end

  class << self
    private

    ##################################
    ##                              ##
    ##  Seeing if there is a match  ##
    ##                              ##
    ##  Matches will between 0-1    ##
    ##  1 for exact match           ##
    ##  0.5 for similar category    ##
    ##  0 for nothing               ##
    ##                              ##
    ##################################

    def generic_field_cluster_match(student, alum, field, clusters)
      # For exact matches
      return 1 if student.data[field] == alum.data[field]

      # For cluster matches
      clusters.each do |cluster|
        if cluster.include?(student.data[field]) and cluster.include?(alum.data[field])
          return 0.5
        end
      end

      if student.data[field] == NO_PREF_STRING
        return NO_OPINION_WEIGHT # give preference to people who have an opinion
      else
        return 0 # no match on industry
      end
    end

    def generic_field_binary_match(student, alum, s_field, a_field)
      return 1 if student.data[s_field] == alum.data[a_field]
      return NO_OPINION_WEIGHT if student.data[s_field] == NO_PREF_STRING
      return 0
    end

    ##################################
    ##                              ##
    ##        Actual fields         ##
    ##                              ##
    ##################################

    def industry(student, alum)
      consumer      = ["Consumer Products",
                       "Consumer Products - Beauty",
                       "Consumer Products - Fashion / Retail",
                       "Consumer Products - Food / Beverage"]
      energy        = ["Energy",
                       "Energy - Clean Energy",
                       "Energy - Oil & Gas"]
      entertainment = ["Entertainment / Media", 
                       "Entertainment / Media - Sports"]
      healthcare    = ["Healthcare",
                       "Healthcare - Biomedical",
                       "Healthcare - Healthcare Related Services",
                       "Healthcare - Pharmaceutical",
                       "Healthcare - Wellness"]
      technology    = ["Technology",
                       "Technology - Consumer Electronics",
                       "Technology - E-Commerce",
                       "Technology - Equipment / Hardware / Networking",
                       "Technology - Software",
                       "Technology - Telecommunications"]

      clusters = [consumer, energy, entertainment, healthcare, technology]
      generic_field_cluster_match(student, alum, "Industry", clusters)
    end

    def function(student, alum)
      finance   = ["Financial Services",
                   "Financial Services - Hedge Fund",
                   "Financial Services - Impact Investing",
                   "Financial Services - Investment Banking",
                   "Financial Services - Investment Management",
                   "Financial Services - Private Equity",
                   "Financial Services - Search Fund",
                   "Financial Services - Venture Capital",
                   "Fundraising / Development"]
      gm        = ["General Management",
                   "General Management - Logistics",
                   "General Management - Manufacturing / Operations",
                   "General Management - Project Management"]
      marketing = ["Marketing",
                   "Marketing - Advertising",
                   "Marketing - Brand Management",
                   "Marketing - Sales"]
      product   = ["Product Development",
                   "Product Management"]

      clusters = [finance, gm, marketing, product]
      generic_field_cluster_match(student, alum, "Function", clusters)
    end

    def geography(student, alum)
      asia   = ["Asia: China",
                "Asia: East",
                "Asia: Hong Kong, SAR",
                "Asia: India",
                "Asia: Southeast"]
      europe = ["Europe: Eastern",
                "Europe: UK",
                "Europe: Western"]
      latam  = ["Latin America: All Other",
                "Latin America: Brazil"]
      africa = ["Middle East / North Africa",
                "Sub-Saharan Africa"]
      us     = ["US",
                "US: Mid-Atlantic (Other)",
                "US: Mid-Atlantic (Washington D.C)",
                "US: Midwest (Chicago)",
                "US: Midwest (Other)",
                "US: Northeast (Boston)",
                "US: Northeast (New York City)",
                "US: Northeast (Other)",
                "US: South (Atlanta)",
                "US: South (Other)",
                "US: Southwest (Other)",
                "US: Southwest (Texas)",
                "US: West Coast (Bay Area)",
                "US: West Coast (Los Angeles)",
                "US: West Coast (Other)",
                "US: West Coast (Pacific Northwest)"]
      clusters = [asia, europe, latam, africa, us]
      generic_field_cluster_match(student, alum, "Geography", clusters)
    end

    def gender(student, alum)
      generic_field_cluster_match(student, alum, "Gender", [])
    end

    def race(student, alum)
      generic_field_cluster_match(student, alum, "Race / Ethnicity", [])
    end

    def sexual_orientation(student, alum)
      s = "Would you prefer a mentor that is LGBT?"
      a = "Do you identify as LGBT?"

      generic_field_binary_match(student, alum, s, a)
    end

    def military(student, alum)
      s = "Would you prefer a mentor with a military background?"
      a = "Do have a military background?"

      generic_field_binary_match(student, alum, s, a)
    end

    def joint_degree(student, alum)
      s = "Would you prefer a mentor with a joint degree?"
      a = "Do you have a joint degree?"

      generic_field_binary_match(student, alum, s, a)
    end

    def family_business(student, alum)
      s = "Would you prefer a mentor from a family business?"
      a = "Have you worked in a family business?"

      generic_field_binary_match(student, alum, s, a)
    end

    ##################################
    ##                              ##
    ##       Preference Order       ##
    ##                              ##
    ##################################

    def coefficient(student, query)
      index = student.data[query].to_i - 1
      PREF_WEIGHTS[index]
    end
  end
end
