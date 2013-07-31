# How to find Network UUID for interfaces.yaml

## Steps

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


      This gives the list of organizations you have access to, and you can choose the one you need by using the name attribute `<Org type="application/vnd.vmware.vcloud.org+xml" name="ORG-NAME" href="https://vendor-api-url.net/org/{org-code}"/>`

   * Get details of the organisation

        curl -v --insecure -H "x-vcloud-authorization: {x-vcloud-auth-code}"
          -H "Accept: application/*+xml;version=5.1"
          "https://vendor-api-url.net/org/{org-code}"

      * This also gives details about various vdc. We would need the one for management vdc:

            <Link rel="down" type="application/vnd.vmware.vcloud.vdc+xml"
              name="Management - GDS Development (SL1)"
              href="https://vendor-api-url.net/vdc/{vdc-uuid}"/>

    * Get vdc details

        curl -v --insecure -H "x-vcloud-authorization: {x-vcloud-auth-code}"
          -H "Accept: application/*+xml;version=5.1"
          "https://vendor-api-url.net/vdc/{vdc-uuid}

      * This would provide you with available networks. From which you
        can use the name and href attributes for adding to your
        interfaces.yaml

            <AvailableNetworks>
              <Network type="application/vnd.vmware.vcloud.network+xml" name="NetworkTest2"
                  href="https:///vendor-api-url.net/network/{network-uuid-2}"/>
              <Network type="application/vnd.vmware.vcloud.network+xml" name="NetworkTest"
                  href="https:///vendor-api-url.net/network/{network-uuid-1}"/>
            </AvailableNetworks>


