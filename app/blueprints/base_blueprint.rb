# All blueprints inherit from here.
# Shared config: timestamps always rendered as ISO-8601 strings.
class BaseBlueprint < Blueprinter::Base
  # Render timestamps consistently as ISO-8601 so API consumers
  # don't have to guess the format.
  field(:created_at) { |obj| obj.created_at&.iso8601 }
  field(:updated_at) { |obj| obj.updated_at&.iso8601 }
end
