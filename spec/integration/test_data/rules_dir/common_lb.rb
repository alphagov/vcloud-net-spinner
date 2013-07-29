load_balancer do
  configure "Frontend" do
    pool ["20.2.0.1", "20.3.0.2"] do
      http
      https
    end

    virtual_server :name => "VDC-1", :interface => "VDC-1", :ip => "20.1.0.2"
  end
end
