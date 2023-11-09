# Generated Secret

This example shows how to use the Terraform [random](https://registry.terraform.io/providers/hashicorp/random/latest/docs)
provider to generate a random secret value which is replication automatically.

## Example at a glance

|Item|Managed by module|Description|
|----|-----------------|-----------|
|Access Control||Not managed by example; permissions to read the secret must be specified externally.|
|Replication|&check;|Automatically managed by Secret Manager.|
|Secret Value|&check;|Generated by example.|

<!-- spell-checker: disable -->
### Example terraform.tfvars

```properties
# Example TF vars file
project_id = "my-project-id"
id = "my-secret-id"
```

### Example commands

Terraform may complain that the module is using a dynamic value and it can't be
used in `for_each` arguments. To work around this apply in two steps:

```shell
terraform init
terraform apply -target random_string.secret
terraform apply
```