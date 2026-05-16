# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ReveChatDemoPod' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ReveChatDemoPod
  # pod 'SocketRocket'
  # pod 'AFNetworking'
  # pod 'GoogleWebRTC'
  pod 'ReveChatSDK'

end

# Xcode 26.4+ rejects #import <netinet6/in6.h> in pods (private system header).
# Redundant with <netinet/in.h>; safe to remove for AFNetworking reachability.
post_install do |installer|
  af_dir = File.join(installer.sandbox.root, 'AFNetworking', 'AFNetworking')
  next unless File.directory?(af_dir)
  import_line = '#import <netinet6/in6.h>'
  Dir.glob(File.join(af_dir, '**', '*.{h,m}')).each do |path|
    lines = File.readlines(path)
    filtered = lines.reject { |l| l.strip == import_line }
    File.write(path, filtered.join) if filtered.size != lines.size
  end
end