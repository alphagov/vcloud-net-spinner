# How to find Network UUID for interfaces.yaml


Using: [VCloud Tools](https://github.com/alphagov/vcloudtools)


## Logging into VCloud

```
#$> export VCLOUD_API_ROOT=https://api.vcd.example.com/api eval `vcloud-login`
Please log into vCloud
Username: username@organisation
Password:
```

## Finding the organisation uuid

```
#$> vcloud-browse /org | grep MyOrg
    <Org type="application/vnd.vmware.vcloud.org+xml" name="MyOrg" href="https://api.vcd.example.com/api/org/77595ec2-2391-4817-9257-66b12533d684"/>
```

In this example, the Org UUID is `77595ec2-2391-4817-9257-66b12533d684`

## Finding the VDC

```
#$> vcloud-browse /org/77595ec2-2391-4817-9257-66b12533d684 | grep vnd.vmware.vcloud.vdc+xml
    <Link rel="down" type="application/vnd.vmware.vcloud.vdc+xml" name="VDC1" href="https://api.vcd.example.com/api/vdc/4887d502-5873-4d0c-bb63-075792277ec6"/>
```

## Finding the Networks in that VDC


```
#$> vcloud-browse /vdc/4887d502-5873-4d0c-bb63-075792277ec6


            <AvailableNetworks>
              <Network type="application/vnd.vmware.vcloud.network+xml" name="Net2"
                  href="https://api.vcd.example.com/api/network/6d0349da-ccd7-4f7a-a4af-71899bf7f12a"/>
              <Network type="application/vnd.vmware.vcloud.network+xml" name="Net1"
                  href="https://api.vcd.example.com/api/network/4e376bed-5d4c-4748-9d0d-1469b24f31c0"/>
            </AvailableNetworks>
```

