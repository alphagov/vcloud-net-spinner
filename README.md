# Vcloud Network Configurator

This is ruby gem which provides a dsl to configure firewall, nat and
loadbalancer rules. It is a wrapper around the network components of
vcloud api.

## Installation

    gem install vcloud_network_configurator

  * Note: It is work in progress, and currently you would have to build
    them gem locally using the following commands

        git clone git@github.com:alphagov/vcloud_network_configurator.git
        gem build vcloud_network_configurator.gemspec
        gem install ./vcloud_network_configurator-0.1.0.gem

## Usage

    Usage: vcloud_configure_edge_gateway [options] API_URL
        -u, --username=U                         Vcloud Username
        -p, --password=P                         Vcloud Password
        -e, --env=E                              Environment: preview | staging | production
        -U, --organization-edgegateway-uuid=U    UID: This is required to configure edgegateway services. For more info refer to
                                                  docs/find_organisation_edgegateway_uuid
        -c, --component=c                        Environment: lb|firewall|nat
        -o, --organization=o                     Organization: optional. Will default to environment
        -d, --rule-directory=d                   Rules Directory: From where to read the NAT/Firewal/LB rules

  Note: organization maps to the organization name in vcloud. Whereas,
        environment maps to your internal environment reference (e.g.
        preview, qa, staging, production, etc)

### Example

      vcloud_configure_edge_gateway -u username -p password -e preview -U 1yenz127ynz1872eyz12yz817e -c firewall -o development -d . http://vcloud.vendor.com/api

### Rules Directory

A particular rules directory structure could be as follows.

        .
        ├── Gemfile
        ├── Gemfile.lock
        ├── common_firewall.rb
        ├── common_lb.rb
        ├── common_nat.rb
        ├── env1
        │   ├── firewall.rb
        │   ├── interfaces.yaml
        │   ├── lb.rb
        │   └── nat.rb
        ├── env2
            ├── firewall.rb
            ├── interfaces.yaml
            ├── lb.rb
            └── nat.rb

* Here each environment represent a separate organisation with your vcloud
  vendor (eg qa, staging, production). These could have specific rules for nat,
  firewall. Also these can have common firewall rules which could be shared
  across all environments. A common example of such a situation is internal
  network firewall rules are usually shared across environments, whereas
  external network firewall rules would be different for all environment.

  * Specific network rules => `env1/firewall.rb`, `env1/nat.rb`, `env1/lb.rb`
  * Common network rules => `./common_firewall.rb`, `./common_lb.rb`, `./common_lb.rb`

* interfaces.yaml file:

        interface:
          VDC-1: "https://localhost:4567/api/admin/network/<vdc-network-uuid>"
          VDC-2: "https://localhost:4567/api/admin/network/<vdc-network-uuid>"

### DSL

#### Firewall

    firewall do
      rule "<description>" do
         source      :ip => "172.10.0.0/8"
         destination :ip => "172.10.0.5", :port => 4567
      end
    end

#### NAT

    nat do
        snat :interface => "<key-from-interfaces.rb>", :original => { :ip => "internal-ip" }, :translated => { :ip => "external-ip" }, :desc => "description"
        dnat :interface => "<key-from-interfaces.rb>", :original => { :ip => "external-ip", :port => 22 }, :translated => { :ip => "internal-ip", :port => 22 },  :desc => "SSH"
    end


#### Load Balancer

    load_balancer do
      configure "description-1" do
        pool ["<ip-1>", "<ip-2>"] do
          http
          https
        end

        virtual_server :name => "description-1", :interface => "<key-from-interfaces.rb>", :ip => "<vse-ip>"
      end

      configure "description-2" do
        pool ["<ip-1>", "<ip-2>", "<ip-3>"] do
          http :port => 8080, :health_check_path => "</router/healthcheck>"
          https
        end

        virtual_server :name => "description-2", :interface => "<key-from-interfaces.rb>", :ip => "<vse-ip>"
      end
    end
