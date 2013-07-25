nat do
    snat :interface => "<key-from-interfaces.rb>", :original => { :ip => "internal-ip" }, :translated => { :ip => "external-ip" }, :desc => "description"
    dnat :interface => "<key-from-interfaces.rb>", :original => { :ip => "external-ip", :port => 22 }, :translated => { :ip => "internal-ip", :port => 22 },  :desc => "SSH"
end
