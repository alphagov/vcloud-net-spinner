nat do
    snat :interface => "VDC-1", :original => { :ip => "internal-ip" }, :translated => { :ip => "external-ip" }, :desc => "description"
    dnat :interface => "VDC-1", :original => { :ip => "external-ip", :port => 22 }, :translated => { :ip => "internal-ip", :port => 22 },  :desc => "SSH"
end
