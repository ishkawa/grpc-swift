require 'xcodeproj'
project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)

# Remove targets that we do not want Carthage to build, and set the deployment target to 9.0.
carthage_targets = ["BoringSSL", "CgRPC", "SwiftGRPC"]
targets_to_remove = project.targets.select { |target| !carthage_targets.include?(target.name) }
targets_to_remove.each do |target|
  target.remove_from_project
end

swift_grpc_target = project.targets.select { |target| target.name == "SwiftGRPC" }[0]

spm_swift_protobuf_framework_ref = swift_grpc_target.frameworks_build_phase.files.select { |file| file.display_name == "SwiftProtobuf.framework" }[0]
swift_grpc_target.frameworks_build_phase.remove_file_reference(spm_swift_protobuf_framework_ref)

carthage_swift_protobuf_framework_ref = project.new_file("Carthage/Build/iOS/SwiftProtobuf.framework")
swift_grpc_target.frameworks_build_phase.add_file_reference(carthage_swift_protobuf_framework_ref)

project.save
