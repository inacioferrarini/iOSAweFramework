desc "Builds Carthage dependencies without updating"
task :cartbuild do
    sh "carthage build --use-xcframeworks --no-use-binaries --platform iOS"
end

desc "Updates and builds Carthage dependencies"
task :cartupdate do
    sh "carthage update --use-xcframeworks --no-use-binaries --platform iOS"
end