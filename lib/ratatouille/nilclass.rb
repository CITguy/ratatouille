# MonkeyPatch NilClass to return true for empty?
class NilClass
  def empty?
    return true
  end
end
