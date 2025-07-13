# image_converter/image_converter_core.rb
# Core functionality for Image to Geometry Converter

module ImageToGeometryConverter

  # --- Public Methods ---

  def self.convert_images
    model = Sketchup.active_model
    model.start_operation("Convert Images to Geometry", true)

    # --- New Feedback Logic ---
    # 1. First, get a total count of images for the progress bar
    total_images = _count_images_recursive(model.entities)

    if total_images == 0
      UI.messagebox("No Image entities found to convert.")
      model.abort_operation # No need to commit an empty operation
      return
    end
    # --- End New Feedback Logic ---

    converted_count = 0
    begin
      # The recursive method does the work, now with feedback parameters
      converted_count = process_context([], 0, total_images)

      UI.messagebox("Successfully converted #{converted_count} image(s) to geometry.")
      puts "Image Converter: #{converted_count} images converted to geometry."

      model.commit_operation
    rescue => e
      model.abort_operation
      UI.messagebox("Error during conversion: #{e.message}")
      puts "Image Converter Error: #{e.message}"
      puts e.backtrace
    ensure
      # Always ensure the user is returned to the model root and status bar is cleared
      model.active_path = nil
      Sketchup.set_status_text("") # Clear status bar
    end
  end

  def self.count_images
    model = Sketchup.active_model
    count = _count_images_recursive(model.entities)
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
    puts "--------------------------"
    UI.messagebox("Diagnostics complete. Check the Ruby Console for details.")
  end

  # --- Private Methods ---

  private

  def self._count_images_recursive(entities)
    count = 0
    entities.each do |entity|
      if entity.is_a?(Sketchup::Image)
        count += 1
      elsif entity.is_a?(Sketchup::Group)
        count += _count_images_recursive(entity.entities)
      elsif entity.is_a?(Sketchup::ComponentInstance)
        count += _count_images_recursive(entity.definition.entities)
      end
    end
    count
  end

  # Recursively processes a context, now with feedback parameters
  def self.process_context(path, count, total_images)
    model = Sketchup.active_model
    model.active_path = path

    # --- New Feedback Logic ---
    context_name = path.empty? ? "Model Root" : path.last.name || path.last.definition.name
    Sketchup.set_status_text("Processing: #{context_name}...")
    # --- End New Feedback Logic ---

    images_to_convert = model.active_entities.grep(Sketchup::Image)

    images_to_convert.each do |image|
      if image.explode
        count += 1
        # --- New Feedback Logic ---
        Sketchup.set_status_text("Converted #{count} of #{total_images} images...")
        # --- End New Feedback Logic ---
      end
    end

    containers = model.active_entities.select do |e|
      e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
    end

    containers.each do |container|
      # Recurse with the updated count
      count = process_context(path + [container], count, total_images)
    end

    return count
  end

end