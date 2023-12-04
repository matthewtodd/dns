I have a couple of scripts to help in my dotfiles:

[with-aws-credentials][] sets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
to values pulled from 1Password.

[private-s3-bucket][] creates an s3 bucket with no possibility of public
access, useful for storing Terraform state.

Using those, getting started here looked like:

```
with-aws-credentials private-s3-bucket matthewtodd.org-terraform
with-aws-credentials terraform init
with-aws-credentials terraform plan
with-aws-credentials terraform apply
```

[with-aws-credentials]: https://github.com/matthewtodd/dotfiles/blob/65de837f0a8b93ffc249c16e1b53db8ae48a050a/bin/with-aws-credentials
[private-s3-bucket]: https://github.com/matthewtodd/dotfiles/blob/1f351448182f0a3b32739095f0abc09ca524abe6/bin/private-s3-bucket

