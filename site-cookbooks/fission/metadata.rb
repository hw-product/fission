name             "fission"
maintainer       "YOUR_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures fission"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends 'pkg-build'
depends "ruby_installer"
depends "omnibus_updater"
depends "git"
depends "ubuntu"
depends "apt"
