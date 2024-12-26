#!/bin/bash

# Install required tools on the ADO agent vm and connect to ADO
agentuser=${AGENT_USER}
pool=${AGENT_POOL}
pat=${AGENT_TOKEN}
azdourl=${AZDO_URL}
region=${REGION}

sudo lvextend -L +2G /dev/mapper/rootvg-homelv -r
sudo lvextend -L +2G /dev/mapper/rootvg-rootlv -r

echo "$(date "+%F %T") INFO:  Configuring this machine to function as an Azure DevOps agent"
set -ex

echo "$(date "+%F %T") INFO:  Running as $(whoami)"

echo "$(date "+%F %T") INFO:  Updating Package Managers"
sudo yum -y update
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y

# install misc tools
echo "$(date "+%F %T") INFO:  Installing miscellaneous build tools"
#sudo dnf -y install jq
sudo dnf -y install git
#sudo dnf -y install unzip

# install az cli
echo "$(date "+%F %T") INFO:  Installing az cli"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf -y install https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
sudo dnf -y install azure-cli


# install terraform
echo "$(date "+%F %T") INFO:  Installing Terraform"
#sudo yum  -y install yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

terraform -help

# install Checkov
sudo dnf -y install python3.11

sudo update-alternatives --set python3 /usr/bin/python3.11
wget -q https://bootstrap.pypa.io/get-pip.py -P /tmp

python3.11 /tmp/get-pip.py
pip install checkov

checkov -h

# install docker
#sudo dnf -y install dnf-plugins-core
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

docker --help

#sudo yum -y update

# install kubectl
echo "$(date "+%F %T") INFO:  Installing Kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
echo "$(date "+%F %T") INFO:  Installing Docker"

kubectl version --client


# install Powershell
# Install pre-requisite packages.
echo "$(date "+%F %T") INFO:  Installing Powershell"
#sudo yum -y update
sudo dnf -y install https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/powershell-7.4.6-1.rh.x86_64.rpm



# install dotnet
#sudo yum -y update
sudo dnf -y install dotnet-sdk-9.0
#sudo dnf -y install aspnetcore-runtime-9.0
#sudo dnf -y install dotnet-runtime-9.0

# install node/npm
sudo dnf -y groupinstall "Development Tools" 
sudo dnf module list nodejs
sudo dnf -y module install nodejs


# Download azdo agent
echo "$(date "+%F %T") INFO:  Downloading Azure DevOps Agent"
sudo mkdir -p /opt/azdo && cd /opt/azdo
sudo cd /opt/azdo
sudo curl -o azdoagent.tar.gz https://vstsagentpackage.azureedge.net/agent/3.248.0/vsts-agent-linux-x64-3.248.0.tar.gz
sudo tar xzf azdoagent.tar.gz
sudo rm -f azdoagent.tar.gz

# configure as azdouser
echo "$(date "+%F %T") INFO:  Configuring Azure DevOps Agent"
#chown -R $agentuser /opt/azdo
sudo chmod -R 755 /opt/azdo

running=$(/opt/azdo/svc.sh status | grep "active (running)" | wc -l)
if (( running == 1 )); then
  echo "$(date "+%F %T") INFO:  AZDO service is already running."
else
  echo "$(date "+%F %T") INFO:  Configuring the Azure DevOps Agent"
  runuser -l $agentuser -c "/opt/azdo/config.sh --unattended --url $azdourl --auth pat --token $pat --pool $pool --acceptTeeEula"
  #sudo /opt/azdo/config.sh --unattended --url $azdourl --auth pat --token $pat --pool $pool --acceptTeeEula

  echo "$(date "+%F %T") INFO:  Setting Agent Capablitlies..."

  echo "Azure.Region=$region" >> "/opt/azdo/.env"

  echo "$(date "+%F %T") INFO:  Installing and Starting Azure DevOps Agent"
  sudo /opt/azdo/svc.sh install
  sudo /opt/azdo/svc.sh start
fi