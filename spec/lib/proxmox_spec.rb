require 'spec_helper'
require 'webmock/rspec'

describe Proxmox do
  before(:each) do
    # Common auth
    stub_request(:post, "http://localhost:8006/api2/json/access/ticket").with(
      :headers => {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'Ruby'
      },
      :body => {
        "username" => "root",
        "password" => "secret",
        "realm" => "pam"
      }
    ).to_return(
      :status => 200,
      :headers => {
        :connection => "close",
        :server => "pve-api-daemon/3.0",
        :content_type => "application/json;charset=UTF-8",
      },
      :body => '{"data":{"cap":{"dc":{"Sys.Audit":1},"access":{"Group.Allocate":1,"User.Modify":1},"nodes":{"Sys.Audit":1,"Sys.Syslog":1,"Sys.Console":1,"Sys.Modify":1,"Sys.PowerMgmt":1},"vms":{"VM.Backup":1,"VM.Allocate":1,"VM.Config.CPU":1,"VM.Config.Network":1,"VM.Migrate":1,"VM.Config.Memory":1,"VM.Config.Options":1,"Permissions.Modify":1,"VM.Monitor":1,"VM.Console":1,"VM.Config.Disk":1,"VM.Config.HWType":1,"VM.Clone":1,"VM.Snapshot":1,"VM.Audit":1,"VM.PowerMgmt":1,"VM.Config.CDROM":1},"storage":{"Datastore.AllocateTemplate":1,"Datastore.Allocate":1,"Datastore.Audit":1,"Permissions.Modify":1,"Datastore.AllocateSpace":1}},"CSRFPreventionToken":"51F00E60:Pnd0AHehuTE++j87nUz0nLuyW+0","ticket":"PVE:root@pam:51F00E60::OS5lBKlaabgnmekdbVY2JYAbd5Z/MPWCeZ9b33UwjsE1yVB1esIwUQoXJ4Xgb/+UVE9mtS2K3dJ65wyPDsGYTDc0TCl0VmdOGz7djXMlMy5ShRjXcX/GLs77LHXlLQOO+ED/jCoz0tHV55igNSBNMG2UrSLlTGvgm8zf1fNqAsVszrAWgeFu+e/1CLIfs//cWyimBuDx+r3m/NOjaoyeb2u63eBCPrWyEiCJZniMZDVnqqQcOm32tE2XQj4D2LS+xaHn2fdZDlcAo0uY4qVspKiMjf9g2AudRblkobCTf7KdhanIm0kCSqkvHJy2EMcAbxcqnGnjPiYSH0WYZMTnlA==","username":"root@pam"}}'
    )
  end

  it 'should connect to Proxmox server' do
    # Bad auth
    stub_request(:post, "http://localhost:8006/api2/json/access/ticket").with(
      :headers => {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'Ruby'
      },
      :body => {
        "username" => "root",
        "password" => "bad",
        "realm" => "pam"
      }
    ).to_return(
      :status => 500,
      :headers => {
        :connection => "close",
        :server => "pve-api-daemon/3.0",
        :content_type => "application/json;charset=UTF-8",
      },
      :body => '{"data":null}'
    )
    server1 = Proxmox::Proxmox.new("http://localhost:8006/api2/json/", "localhost", "root", "secret", "pam")
    server1.status.should == "connected"

    server2 = Proxmox::Proxmox.new("http://localhost:8006/api2/json/", "localhost", "root", "bad", "pam")
    server2.status.should == "error"
  end

  it "should get openvz vm list" do
    # First VM list
    stub_request(:get, "http://localhost:8006/api2/json/nodes/localhost/openvz").with(
      :headers => {
        'User-Agent' => 'Ruby',
        'Cookie' => /.*/,
        'Csrfpreventiontoken' => /.*/
      }
    ).to_return(
      :status => 200,
      :headers => {
        :connection => "close",
        :server => "pve-api-daemon/3.0",
        :content_type => "application/json;charset=UTF-8",
      },
      :body => '{"data":[{"maxswap":536870912,"disk":404037632,"ip":"192.168.1.5","status":"running","netout":272,"maxdisk":4294967296,"maxmem":536870912,"uptime":3847,"swap":0,"vmid":"101","nproc":"10","diskread":0,"cpu":0.00183354942808597,"netin":0,"name":"test2.dummy.tld","failcnt":0,"diskwrite":0,"mem":21303296,"type":"openvz","cpus":1},{"maxswap":536870912,"disk":387186688,"ip":"192.168.1.1","status":"running","netout":272,"maxdisk":4294967296,"maxmem":536870912,"uptime":17120,"swap":0,"vmid":"100","nproc":"17","diskread":0,"cpu":0.000504170031344927,"netin":0,"name":"test.dummy.tld","failcnt":0,"diskwrite":0,"mem":27987968,"type":"openvz","cpus":1}]}'
    )

    # Second VM list
    stub_request(:get, "http://localhost:8006/api2/json/nodes/otherone/openvz").with(
      :headers => {
        'User-Agent' => 'Ruby',
        'Cookie' => /.*/,
        'Csrfpreventiontoken' => /.*/
      }
    ).to_return(
      :status => 200,
      :headers => {
        :connection => "close",
        :server => "pve-api-daemon/3.0",
        :content_type => "application/json;charset=UTF-8",
      },
      :body => '{"data":[{"maxswap":536870912,"disk":404041728,"ip":"192.168.1.5","status":"running","netout":272,"maxdisk":4294967296,"maxmem":536870912,"uptime":6176,"swap":0,"vmid":"101","nproc":"10","diskread":0,"cpu":0.00161487378340585,"netin":0,"name":"test2.dummy.tld","failcnt":0,"diskwrite":0,"mem":21299200,"type":"openvz","cpus":1},{"maxswap":2147483648,"disk":0,"ip":"10.0.0.1","status":"stopped","netout":0,"maxdisk":10737418240,"maxmem":1073741824,"uptime":0,"swap":0,"vmid":"102","nproc":0,"diskread":0,"cpu":0,"netin":0,"name":"test3.other.domain","failcnt":0,"diskwrite":0,"mem":0,"type":"openvz","cpus":2},{"maxswap":536870912,"disk":387194880,"ip":"192.168.1.1","status":"running","netout":272,"maxdisk":4294967296,"maxmem":536870912,"uptime":19449,"swap":0,"vmid":"100","nproc":"17","diskread":0,"cpu":0.000589570582552814,"netin":0,"name":"test.dummy.tld","failcnt":0,"diskwrite":0,"mem":28282880,"type":"openvz","cpus":1}]}'
    )

    server1 = Proxmox::Proxmox.new("http://localhost:8006/api2/json/", "localhost", "root", "secret", "pam")
    server1.openvz.should be_an_instance_of Hash
    server1.openvz.keys.sort.should be_eql [ '100', '101' ]

    server2 = Proxmox::Proxmox.new("http://localhost:8006/api2/json/", "otherone", "root", "secret", "pam")
    server2.openvz.should be_an_instance_of Hash
    server2.openvz.keys.sort.should be_eql [ '100', '101', '102' ]
  end
end