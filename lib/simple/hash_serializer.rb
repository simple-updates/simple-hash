class Simple::HashSerializer
  def self.dump(simple_hash)
    return if simple_hash.nil?
    simple_hash.to_h
  end

  def self.load(hash)
    return if hash.nil?
    Simple::Hash.new(hash)
  end
end
