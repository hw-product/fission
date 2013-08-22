Packomatic.describe do
  target do
    platform 'ubuntu' # keep inline with chef platform values
    package 'deb' # rpm, etc
    arch 'x86_64' # do we care about 32bit?
  end
  dependencies do
    build [package1, package2, package3]
    runtime [package1, package2, package3]
    package.runit do
      source do
        type :internal # :external
        git 'git://github.com/runit/runit.git'
      end
      dependencies do
      end
      build do
      end
    end
  end
  build do
    template :rails
    commands do
      before.dependencies ['comms']
      after.dependencies ['comms']
      before.build ['comms']
      after.build ['comms']
      build ['comms'] # not valid with template set
    end
    configure do
      prefix '/usr/local'
    end
  end
end
