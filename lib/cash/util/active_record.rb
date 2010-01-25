class ActiveRecord::Base
  def <=>(other)
    self.id.to_i <=> other.id.to_i
  end
end