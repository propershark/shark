class Source
  def refresh; raise :subclass_responsibility; end
  def update;  raise :subclass_responsibility; end
end
