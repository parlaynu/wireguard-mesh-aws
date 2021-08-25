# Wireguard VPN Mesh

An example setup of a wireguard VPN mesh on AWS. Uses multiple VPCs as sites, traffic between
sites routed over wireguard in a fully connected mesh configuration.

Includes ssh configurations for local workstation to access all machines, and configs and keys on
each server to test interconnections.

The configuration here creates 4x VPCs and 8x EC2 servers. It uses `t2.micro` spot instances; it doesn't
cost a lot, but running it will incur costs.

[Terraform](https://www.terraform.io/) is used to create the infrastructure.

[Ansible](https://docs.ansible.com/ansible_community.html) is used to configure the servers.

## Setup

### Configuration

Copy the `terraform.tfvars.example` to `terraform.tfvars` and fill in the variables with your 
custom values.

You need to generate wireguard keys in advance - tried to make this work with terraform directly
but couldn't figure it out.

Create the private and public keys with a bash loop like this:

    for site in core site1 site2 site3
    do
        wg genkey | tee ${site}.key | wg pubkey > ${site}.pub
    done

Add the contents of these files into `terraform.tfvars` at the correct location.

### Build The Infrastructure

    terraform apply
    ./local/ansible/run-ansible.sh

### Tear It Down

    terraform destroy


## Using

There is an ssh-config file in `local/ssh.cfg`. To log into a server using it, run:

    ssh -F local/ssh.cfg core-vpn

There is a `~/.ssh/config` file and key installed on each server for accessing servers
across the vpn mesh.

