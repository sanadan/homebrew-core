class Fabio < Formula
  desc "Zero-conf load balancing HTTP(S) router"
  homepage "https://github.com/fabiolb/fabio"
  url "https://github.com/fabiolb/fabio/archive/v1.5.5.tar.gz"
  sha256 "a93beb76a888f39053cb519e87deb600c73975b50629d3ff7275890f51f88691"
  head "https://github.com/fabiolb/fabio.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "09f36232acd99cecb7fc72c871ae442662b9f76c5ca820aa127768f64f6b01b4" => :high_sierra
    sha256 "251af79c27ba551fb48af643e06e0f995cd311db31e14aafc3a028764ec186b8" => :sierra
    sha256 "1d233db6598d6c2f45bcf5bc26feb8fce3be8abcc5860fb4905c40655ead435b" => :el_capitan
    sha256 "cc8e5c3c3dc13503a8b29417cdfcabaa8e1f9bcefb40492becbcefd60b52b0f2" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "consul" => :recommended

  def install
    mkdir_p buildpath/"src/github.com/fabiolb"
    ln_s buildpath, buildpath/"src/github.com/fabiolb/fabio"

    ENV["GOPATH"] = buildpath.to_s

    system "go", "install", "github.com/fabiolb/fabio"
    bin.install "#{buildpath}/bin/fabio"
  end

  test do
    require "socket"
    require "timeout"

    CONSUL_DEFAULT_PORT = 8500
    FABIO_DEFAULT_PORT = 9999
    LOCALHOST_IP = "127.0.0.1".freeze

    def port_open?(ip, port, seconds = 1)
      Timeout.timeout(seconds) do
        begin
          TCPSocket.new(ip, port).close
          true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          false
        end
      end
    rescue Timeout::Error
      false
    end

    if !port_open?(LOCALHOST_IP, FABIO_DEFAULT_PORT)
      if !port_open?(LOCALHOST_IP, CONSUL_DEFAULT_PORT)
        fork do
          exec "consul agent -dev -bind 127.0.0.1"
          puts "consul started"
        end
        sleep 30
      else
        puts "Consul already running"
      end
      fork do
        exec "#{bin}/fabio &>fabio-start.out&"
        puts "fabio started"
      end
      sleep 10
      assert_equal true, port_open?(LOCALHOST_IP, FABIO_DEFAULT_PORT)
      if OS.mac?
        system "killall", "fabio" # fabio forks off from the fork...
      else
        # killall may not be installed on Linux
        system "kill -9 $(pgrep fabio)"
      end
      system "consul", "leave"
    else
      puts "Fabio already running or Consul not available or starting fabio failed."
      false
    end
  end
end
