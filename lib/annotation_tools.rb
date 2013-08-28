module AnnotationTools

  def self.create_regex records
    regex =  "\\b("

    records.each do |record|

        regex += record.name
        regex += '|'
    end
    regex = regex[0..-2]
    regex += ")\\b"
    return regex
  end
end