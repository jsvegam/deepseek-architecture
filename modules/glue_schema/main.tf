resource "aws_glue_registry" "glue_registry" {
  registry_name = "people-data-registry"
}

resource "aws_glue_schema" "glue_schema" {
  schema_name       = "people-schema"
  registry_arn      = aws_glue_registry.glue_registry.arn
  data_format       = "AVRO"
  compatibility    = "BACKWARD"
  schema_definition = jsonencode({
    type = "record",
    name = "Person",
    fields = [
      { name = "name", type = "string" },
      { name = "age",  type = "int" }
    ]
  })
}