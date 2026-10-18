output "team_id" {
  value = random_id.id.hex
}

output "enviroments_folder" {
  value = [for f in local_file.enviroments_folder : f.filename]
}

output "team_files" {
  value = [for f in local_file.teams : f.filename]
}