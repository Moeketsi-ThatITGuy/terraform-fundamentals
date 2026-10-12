resource "random_id" "id"{

byte_length = 8

}

resource "local_file" "read_me"{

  filename = "${var.base_path}/read_me.txt"
  content = "This is the id of the random_id: ${random_id.id.hex}"
  lifecycle{

    create_before_destroy = true
}
}

resource "local_file" "enviroments_folder"{

 for_each = var.enviroments 

  filename = "${var.base_path}/enviroments/${each.value}.txt"
  content  = "This is for the enviroment for ${each.value}"
}

resource "local_file" "teams"{

for_each = var.team_members
filename = "${var.base_path}/roles/${each.key}.txt"
content = "This is the file for ${each.key} with the role ${each.value}"

}

resource "local_file" "log_count"{

  count = var.log_count
  filename = "${var.base_path}/logs/${count.index}.txt"
  content = "This is log file number ${count.index}"
}

data "local_file" "read_back" {
  filename = local_file.read_me.filename
}
