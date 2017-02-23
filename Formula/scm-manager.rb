class ScmManager < Formula
  desc "Manage Git, Mercurial, and Subversion repos over HTTP"
  homepage "https://www.scm-manager.org"
  url "https://maven.scm-manager.org/nexus/content/repositories/releases/sonia/scm/scm-server/1.51/scm-server-1.51-app.tar.gz"
  version "1.51"
  sha256 "a7302f064443c814da44baf961227568575aff110e3e974d0a7d07894f81567f"

  bottle do
    cellar :any_skip_relocation
    sha256 "e8eb9655e638b9b63d983df2921ca46959188bc3c69aaea04df000ad065daca4" => :sierra
    sha256 "d16a74d953954dfbc1d788ae62fe0a279248570d5a5d173949f997020b326962" => :el_capitan
    sha256 "d37319696b700361b7a9e2c0daf3e5f2de6b21bcb69d04bb963c775d73337f65" => :yosemite
    sha256 "10f94fa5dafdb40dbcf6a7744a98b2433e294af16e7712a572de49daaed031e0" => :mavericks
  end

  depends_on :java => "1.7+"

  resource "client" do
    url "https://maven.scm-manager.org/nexus/content/repositories/releases/sonia/scm/clients/scm-cli-client/1.51/scm-cli-client-1.51-jar-with-dependencies.jar"
    version "1.51"
    sha256 "9697f390fb0a3d02a805ea66e9b6bb2b3fdf4d53036ec1bea7348e0872e1baae"
  end

  def install
    rm_rf Dir["bin/*.bat"]

    libexec.install Dir["*"]

    (bin/"scm-server").write <<-EOS.undent
      #!/bin/bash
      BASEDIR="#{libexec}"
      REPO="#{libexec}/lib"
      export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)
      "#{libexec}/bin/scm-server" "$@"
    EOS
    chmod 0755, bin/"scm-server"

    tools = libexec/"tools"
    tools.install resource("client")

    scm_cli_client = bin/"scm-cli-client"
    scm_cli_client.write <<-EOS.undent
      #!/bin/bash
      java -jar "#{tools}/scm-cli-client-#{version}-jar-with-dependencies.jar" "$@"
    EOS
    chmod 0755, scm_cli_client
  end

  plist_options :manual => "scm-server start"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/scm-server</string>
          <string>start</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scm-cli-client version")
  end
end
