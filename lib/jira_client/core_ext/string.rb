class String

  def underscore
    self.gsub(/::/, '/').gsub(/([a-z]+)([A-Z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1\2').tr("-", "_").downcase
  end

end