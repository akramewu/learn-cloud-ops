# Create a DynamoDB Table
resource "aws_dynamodb_table" "my_dynamodb_table" {
  name           = "myapp-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "MyDynamoDBTable"
  }
}