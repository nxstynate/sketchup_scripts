# image_converter/image_converter_core.rb
# Core functionality for Image to Geometry Converter

module ImageToGeometryConverter

  # --- Public Methods ---

  def self.convert_images
    model = Sketchup.active_model
    model.start_operation("Convert Images to Geometry", true)
    
    converted_count = 0
    begin
      # The recursive method does the work, starting with an empty path (model root)
      converted_count = process_context([])
      
      UI.messagebox("Successfully converted #{converted_count} image(s) to geometry.")
      puts "Image Converter: #{converted_count} images converted to geometry."
      
      model.commit_operation
    rescue => e
      model.abort_operation
      UI.messagebox("Error during conversion: #{e.message}")
      puts "Image Converter Error: #{e.message}"
      puts e.backtrace
    ensure
      # Always ensure the user is returned to the model root
      model.active_path = nil
    end
  end

  def self.count_images
    model = Sketchup.active_model
    count = 0
    
    # Use a simple recursive proc for read-only counting
    proc = lambda do |entities_collection|
      entities_collection.each do |entity|
        if entity.is_a?(Sketchup::Image)
          count += 1
        elsif entity.is_a?(Sketchup::Group)
          proc.call(entity.entities)
        elsif entity.is_a?(Sketchup::ComponentInstance)
          proc.call(entity.definition.entities)
        end
      end
    end

    proc.call(model.entities)
    
    UI.messagebox("Found #{count} Image entit#{count == 1 ? 'y' : 'ies'} in the model.")
  end

  def self.run_diagnostics
    model = Sketchup.active_model
    puts "--- Starting Model Diagnostics ---"
    
    results = { images: 0, faces_with_textures: 0, groups: 0, components: 0 }
    
    # Use a recursive proc for read-only diagnostics
    proc = lambda do |entities, path_str|
      entities.each do |entity|
        if entity.is_a?(Sketchup::Image)
          results[:images] += 1
          puts "Found Sketchup::Image in context: #{path_str}"
        elsif entity.is_a?(Sketchup::Face) && entity.material && entity.material.texture
          results[:faces_with_textures] += 1
          puts "Found Sketchup::Face with texture '#{entity.material.name}' in context: #{path_str}"
        elsif entity.is_a?(Sketchup::Group)
          results[:groups] += 1
          proc.call(entity.entities, "#{path_str} > Group(#{entity.name})")
        elsif entity.is_a?(Sketchup::ComponentInstance)
          results[:components] += 1
          proc.call(entity.definition.entities, "#{path_str} > Component(#{entity.definition.name})")
        end
      end
    end
    
    proc.call(model.entities, "Model Root")
    
    puts "--- Diagnostics Summary ---"
    puts "  Sketchup::Image entities: #{results[:images]}"
    puts "  Faces with textures: #{results[:faces_with_textures]}"
    puts "  Groups found: #{results[:groups]}"
    puts "  Component Instances found: #{results[:components]}"
    puts "---------------------------"
    UI.messagebox("Diagnostics complete. Check the Ruby Console for details.")
  end

  # --- Private Methods ---

  private

  # Recursively processes a context (an array of entities forming a path)
  def self.process_context(path, count = 0)
    model = Sketchup.active_model
    
    # Set the model's active context. This is the key to making explode work.
    model.active_path = path
    
    # Find all images in the current context
    # Grep is used to create a static copy so we can modify the collection
    images_to_convert = model.active_entities.grep(Sketchup::Image)
    
    images_to_convert.each do |image|
      if image.explode
        count += 1
      end
    end
    
    # Find all containers in the current context and recurse into them
    containers = model.active_entities.select do |e|
      e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    end
    
    containers.each do |container|
      # Recurse by calling this method with the extended path
      count = process_context(path + [container], count)
    end
    
    return count
  end

end