# frozen_string_literal: true

def attributes_to_graphql(attributes)
  payload = attributes.map do |key, value|
    case value
    when Hash
      "#{key}: #{attributes_to_graphql(value)}"
    when Array, Integer, Float
      "#{key}: #{value.to_json}"
    when String
      %(#{key}: "#{value.gsub('"', '\"')}")
    end
  end

  "{ #{payload.join(", ")} }"
end
