## Terraform
```
https://hashicorp-releases.yandexcloud.net/terraform/
https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart
```
##  Oh My ZSH!
```
https://ohmyz.sh/
```

## packages 
```
apt-get update && apt-get upgrade -y && apt-get install -y locales && localedef -i en_US -c -f -A /usr/share/locale/locale.alias en_US.UTF-8
```
## kubectl
```
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
&& echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
&& apt-get update \
&& apt-get install -y kubectl
```
## terraform   (обязательно версии 0.12.29)
```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - &&\
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" &&\
    apt-get update && apt-get install -y terraform=0.12.29
```

## terragrunt
```
curl -L -o /usr/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.23.39/terragrunt_linux_amd64 &&\
    chmod +x /usr/bin/terragrunt
```
## k9s
```
curl -fsSL https://github.com/derailed/k9s/releases/download/v0.24.9/k9s_Linux_x86_64.tar.gz | tar -C /usr/bin/ -xz k9s && chmod +x /usr/bin/k9s
```
## Yandex CLI
```
curl -O https://storage.yandexcloud.net/yandexcloud-yc/install.sh \
    && bash install.sh -a -i /usr/yandex-cloud -r /etc/bash.bashrc
    #/etc/profile
    #curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash -s -- -a
```
## yq
```
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
chmod +x /usr/bin/yq
yq --version
```
## helm
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
## multiple versions of Terragrunt and Terraform
https://github.com/warrensbox/terraform-switcher
https://github.com/warrensbox/tgswitch
```
curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
```