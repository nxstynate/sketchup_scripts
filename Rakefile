
# Rakefile for building the Image Converter .rbz extension

require 'rake'

# --- Configuration ---
PLUGIN_NAME = "image_converter"
# Files and folders to be included in the .rbz package
PLUGIN_FILES = FileList[
  "image_converter.rb",
  "image_converter/**/*"
]
# The final package name
RBZ_FILE = "dist/#{PLUGIN_NAME}.rbz"

# --- Tasks ---

# Default task: running 'rake' in the terminal will show this message
task :default do
  puts "Rake tasks for #{PLUGIN_NAME}:"
  puts "  rake build  - Build the .rbz file for distribution."
  puts "  rake clean  - Remove the built .rbz file."
end

# Build task: creates the .rbz file
desc "Build the .rbz file for distribution"
task :build do
  puts "Building #{RBZ_FILE}..."
  
  # Create the 'dist' directory if it doesn't exist
  mkdir_p "dist"
  
  # Use the system's zip command to create the archive.
  # This is a reliable method that doesn't require extra gems.
  # The command will be run from the project root.
  sh "zip -r #{RBZ_FILE} #{PLUGIN_FILES.join(' ')}"
  
  puts "Successfully built #{RBZ_FILE}"
end

# Clean task: removes the built package
desc "Remove the built .rbz file"
task :clean do
  if File.exist?(RBZ_FILE)
    puts "Cleaning #{RBZ_FILE}..."
    rm RBZ_FILE
    puts "Clean complete."
  else
    puts "#{RBZ_FILE} not found, nothing to clean."
  end
end
