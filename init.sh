# OS: Ubuntu 18.04 LTS 
# 這不是自動安裝script
# 官方做法要用root帳號, 但不建議切過去做, 所以前面指令都會有sudo
# 如果需要就用
# sudo su -

# Install Docker (官方步驟)
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce # Ubuntu 18.04 沒有 V17 docker, 直接上最新版
sudo apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

sudo usermod -aG docker $USER

# Install K8S 
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
#sudo apt-get install -y kubelet kubeadm kubectl # release 1.11.9
sudo apt-get install -y kubeadm=1.11.9-00 kubectl=1.11.9-00 kubelet=1.11.9-00

# Disable swap
sudo swapoff -a && sudo sysctl -w vm.swappiness=0
sudo sed '/swap.img/d' -i /etc/fstab


# Init K8S 
sudo kubeadm init \
–service-node-port-range=30000-65530 \
--pod-network-cidr=10.244.0.0/16


# Get K8s control 
mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Enable scheduling pods on Master
kubectl taint nodes --all node-role.kubernetes.io/master-

# Install network plugin
sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml


# Install traefik (Ingress Controller)
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik-ds.yaml
