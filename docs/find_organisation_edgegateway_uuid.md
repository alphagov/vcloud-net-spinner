# How to find the Edge Gateway UUID

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

## Finding the VDC UUID

```
#$> vcloud-browse /org/77595ec2-2391-4817-9257-66b12533d684 | grep vnd.vmware.vcloud.vdc+xml
    <Link rel="down" type="application/vnd.vmware.vcloud.vdc+xml" name="VDC1" href="https://api.vcd.example.com/api/vdc/4887d502-5873-4d0c-bb63-075792277ec6"/>
```
In this example, the VDC UUID is `4887d502-5873-4d0c-bb63-075792277ec6`

## Find the Edge Gateway UUID

```
#$> vcloud-browse /admin/vdc/4887d502-5873-4d0c-bb63-075792277ec6/edgeGateways\?format=references | grep 'EdgeGatewayReference '
    <EdgeGatewayReference type="application/vnd.vmware.admin.edgeGateway+xml" name="My VSE (nft00012a3)" id="urn:vcloud:gateway:be8e9731-0f3d-474b-b739-085afd27cdfd" href="https://api.vcd.example.com/api/admin/edgeGateway/be8e9731-0f3d-474b-b739-085afd27cdfd"/>
```
In this example, the Edge Gateway UUID is `be8e9731-0f3d-474b-b739-085afd27cdfd`
