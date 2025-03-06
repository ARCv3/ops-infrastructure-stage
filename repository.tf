
resource "aws_ecr_repository" "repo" {
    name = "arc-api-repo"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration {
        scan_on_push = true
    }
}


