# DEPRECATION NOTICE

This software is old and while it served it's purpose it is no-longer being updated.

The replacement is a suite of ruby gems called [vcloud-tools](http://rubygems.org/gems/vcloud-tools) and you should definitely check those out instead.


# Vcloud Network Configurator

This is ruby gem which provides a dsl to configure firewall, nat and
loadbalancer rules. It is a wrapper around the network components of
vcloud api.

## Installation

    gem install vcloud-net-spinner

## Usage

    Usage: vcloud-net-spinner [options] API_URL
        -u, --username=U                         Vcloud Username
        -p, --password=P                         Vcloud Password
        -U, --organization-edgegateway-uuid=U    UID: This is required to configure edgegateway services. For more info refer to docs/find_organisation_edgegateway_uuid
        -c, --component=c                        Component: lb|firewall|nat
        -o, --organization=o                     Organization: Name of vcloud organization
        -r, --rules-files file1,file2,file3      Rules Files: files which will contain the rules for the component provided
        -i, --interfaces-files file1,file2,file3 Interfaces Files: files which will contain interfaces

### Example

      vcloud-net-spinner -u username -p password -e preview -U 1yenz127ynz1872eyz12yz817e -c firewall -o development -d . http://vcloud.vendor.com/api

### Rules Files & Interfaces Files

* You can pass multiple files containing component rules via
  `--rules-files`.

* You can specify various files containing network interfaces
  rules via `--interfaces-files`.

  A particular `interfaces.yaml` file looks as follows:

        interfaces:
          Network-1: "https://localhost:4567/api/admin/network/<vdc-network-uuid>"
          Network-2: "https://localhost:4567/api/admin/network/<vdc-network-uuid>"

  To find the urls for network, follow the document a
  `docs/find_network_url`


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
