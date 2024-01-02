data "archive_file" "aws-nuke-zip" {
  type             = "zip"
  output_path      = "${path.module}/nuke.zip"
  source_dir       = "${path.module}/nuke"
  output_file_mode = "0666"
}