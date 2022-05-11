#!/bin/sh -eu

if [ "$(id -ur)" -ne "0" ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Set up containerd
echo "==> Setting up containerd..."

## Add required modules
echo "Adding required modules..."
cat <<EOMODCONF | tee /etc/modules-load.d/k8s-containerd.conf
overlay
br_netfilter
EOMODCONF

sudo modprobe overlay
sudo modprobe br_netfilter
echo "Done."

## Configure iptables
echo "Enabling iptables to see bridged traffic, and allow ip forwarding..."
cat <<EOSYSCTLCNF > /etc/sysctl.d/k8s-cri.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOSYSCTLCNF
sysctl --system
echo "Done."

## Install containerd
echo "Installing containerd..."
echo "------------------------"
echo "Adding official docker repository..."
curl -fsSL "https://download.docker.com/linux/debian/gpg" | apt-key add -qq - >/dev/null 2>&1
echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" > /etc/apt/sources.list.d/docker.list
apt-get update && apt-get install -y containerd.io
echo "Configuring containerd..."
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
echo "Setting cgroup driver to systemd"
sed --in-place 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
echo "Starting containerd..."
systemctl restart containerd
echo "------------------------"
echo "Done."
echo

## Install kubelet, kubeadm, kubectl
echo "==> Installing kubelet, kubeadm and kubectl..."

echo "Adding kubernetes apt key..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -qq - >/dev/null 2>&1
echo "Done."
echo "Adding kubernetes apt repository..."
cat <<EOFKUBLIST >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOFKUBLIST
apt-get update -y
echo "Done."
echo "Installing..."
if [ "" = "${KUBE_VERSION:-}" ]; then
    echo "Latest version."
    apt-get install -y kubelet kubeadm kubectl
else
    echo "Version $KUBE_VERSION"
    apt-get install -y kubelet="$KUBE_VERSION" kubeadm="$KUBE_VERSION" kubectl="$KUBE_VERSION"
fi
apt-mark hold kubelet kubeadm kubectl
echo "Done."

## Add kubectl autocomplete
echo "Adding kubectl autocomplete..."
[ -d /etc/bash_completion.d ] || mkdir -p /etc/bash_completion.d
echo "Installing kubectl autocomplete..."
kubectl completion bash >/etc/bash_completion.d/kubectl
echo "Done."

