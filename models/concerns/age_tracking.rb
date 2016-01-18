# Keep track of how old a record's data is
module AgeTracking
  # def self.included base
  #   base.before_save :set_updated_at
  # end

  # def set_updated_at
  #   (self.updated_at = Time.now) if self.respond_to?(:updated_at)
  # end


  def record_age_since time
    time - self.updated_at
  end

  def record_age
    record_age_since Time.now
  end
end
