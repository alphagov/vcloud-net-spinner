firewall do
  rule "allow all boxes to access peppers box on port 22" do
    source :ip => '172.10.0.0/24'
    destination :ip => '172.11.0.1', :port => 22
  end
end
