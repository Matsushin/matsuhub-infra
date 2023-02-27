# Terraform

# Preparation

```
brew install terraform
brew install golang
```


1. Edit  terraform.tfvars

DON'T EXPOSE YOUR access_key and secret_key

```
cp terraform.tfvars.template terraform.tfvars

```
# How to Deploy

terraform を適用するのは deploy.sh のスクリプトを利用します

1. 変更点の確認

```
bash deploy.sh plan
```

2. 実行

```
bash deploy.sh apply
```

`deploy.sh apply` が正常終了すると、`git add` する様にしています。

# CodeBuild

コードビルドを使うのに[github personal token](https://github.com/settings/personal-access-tokens/new) が必要です

利用している権限 

— admin:repo_hook, audit_log, notifications, project, repo, workflow

