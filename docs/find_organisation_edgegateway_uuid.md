# How to find ORGANISATION EDGEGATEWAY UUID

##Steps:

   * vcloud authorization

        curl -v -X POST -d '' -H "Accept: application/*+xml;version=5.1"
          -u "{username}@vcloud-org-name:**********"
          https://vendor-api-url.net/sessions


    The above returns the following information in response
    `x-cloud-authorization` and
    `<Link rel="down" type="application/vnd.vmware.vcloud.orgList+xml" href="https://vendor-api-url.net/org/"/>`


   * List organisations

        curl -v --insecure
          -H "x-vcloud-authorization: {x-vcloud-auth-code}"
          -H "Accept: application/*+xml;version=5.1"
          "https://vendor-api-url.net/org/"


      This gives `<Org type="application/vnd.vmware.vcloud.org+xml" name="GDS-Development" href="https://vendor-api-url.net/org/{org-code}"/>`

   * Get details of the organisation

        curl -v --insecure -H "x-vcloud-authorization: {x-vcloud-auth-code}"
          -H "Accept: application/*+xml;version=5.1"
          "https://vendor-api-url.net/org/{org-code}"

      * This also gives details about various vdc. We would need the one for management vdc:

            <Link rel="down" type="application/vnd.vmware.vcloud.vdc+xml"
              name="Management - GDS Development (SL1)"
              href="https://vendor-api-url.net/vdc/{org-code}"/>

   * Retrieve edgegateway record

        curl -v --insecure -H "x-vcloud-authorization: {x-vcloud-auth-code}="
          -H "Accept: application/*+xml;version=5.1"
          "https://vendor-api-url.net/admin/vdc/{management-edgegateway-uuid}/edgeGateways"

      * Response of the above is (from which you would need the id in the href attribute):

            <EdgeGatewayRecord vdc="https://vendor-api-url.net/vdc/{management-edgegateway-uuid}"
              numberOfOrgNetworks="8" numberOfExtNetworks="1"
              name="GDS Development Gateway" isBusy="false" haStatus="UP" gatewayStatus="READY"
              href="https://vendor-api-url.net/admin/edgeGateway/{id}"
              isSyslogServerSettingInSync="true" taskStatus="success"
              taskOperation="networkConfigureEdgeGatewayServices"
              task="https://vendor-api-url.net/task/***" taskDetails=" "/>

         *e.g. https://vendor-api-url.net/admin/edgeGateway/{id}*



