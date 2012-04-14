# Monkey Patch String class
class String
  def blank?
    return self.chomp.empty?
  end
end
