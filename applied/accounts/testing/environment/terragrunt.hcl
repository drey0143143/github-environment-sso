terraform {
  source = "../../../..//module/tf-code"
}


include {
  path = find_in_parent_folders()
}
