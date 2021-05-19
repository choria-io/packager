desc "Builds and pushes all dockerfiles"

GOVERSION="1.16.4"

_TAGVERSION=GOVERSION.split('.')[0,2].join('.')

task :build do
  Dir.glob("Dockerfile.el6-go") do |file|
    tag = file.split(/Dockerfile\./).last
    nocache = ENV["NOCACHE"] ? "--no-cache" : ""

    if tag
      sh "docker build -f %s %s --build-arg GOVERSION=%s --tag choria/packager:%s%s ." % [file, nocache, GOVERSION, tag, _TAGVERSION]
      sh "docker push choria/packager:%s%s" % [tag, _TAGVERSION]
    end
  end
end
