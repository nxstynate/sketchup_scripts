# image_converter/image_converter_core.rb
# Core functionality for Image to Geometry Converter

module ImageToGeometryConverter
  
  def self.convert_images
    model = Sketchup.active_model
    
    # Start an operation for undo functionality
    model.start_operation("Convert Images to Geometry", true)
    
    begin
      # Counter for converted images
      converted_count = 0
      
      # Clear any existing edit contexts first
      while model.active_path && model.active_path.length > 0
        model.close_active
      end
      
      # Process all entities in the model
      converted_count = process_entities_with_context(model.entities, [], converted_count)
      
      # Make sure we're back to the root context
      while model.active_path && model.active_path.length > 0
        model.close_active
      end
      
      # Commit the operation
      model.commit_operation
      
      # Report results
      if converted_count > 0
        UI.messagebox("Successfully converted #{converted_count} image(s) to geometry.")
        puts "Image Converter: #{converted_count} images converted to geometry."
      else
        UI.messagebox("No Image entities found in the model.")
        puts "Image Converter: No images found to convert."
      end
      
    rescue => e
      # If anything goes wrong, abort the operation and close contexts
      while model.active_path && model.active_path.length > 0
        model.close_active
      end
      model.abort_operation
      UI.messagebox("Error during conversion: #{e.message}")
      puts "Image Converter Error: #{e.message}"
      puts e.backtrace
    end
    
    return converted_count
  end
  
  private
  
  def self.process_entities_with_context(entities, context_path, count = 0)
    model = Sketchup.active_model
    
    # Build context description for logging
    context_desc = context_path.empty? ? "Root" : context_path.join(" > ")
    puts "Processing context: #{context_desc}"
    
    # First, collect all images at this level and convert them
    images_to_convert = []
    entities.each do |entity|
      if entity.is_a?(Sketchup::Image)
        images_to_convert << entity
      end
    end
    
    # Convert images in the current context
    images_to_convert.each do |image|
      if convert_image_in_context(image, context_desc)
        count += 1
      end
    end
    
    # Now process nested containers
    entities.each do |entity|
      case entity
      when Sketchup::Group
        # Enter the group's edit context
        group_name = entity.name || "Unnamed Group"
        puts "Entering group: #{group_name}"
        
        begin
          # Edit the group (equivalent to double-clicking)
          model.edit_entity(entity)
          
          # Process entities within this group context
          new_context_path = context_path + [group_name]
          count = process_entities_with_context(entity.entities, new_context_path, count)
          
          # Exit the group context
          model.close_active
          puts "Exited group: #{group_name}"
          
        rescue => e
          puts "Error processing group '#{group_name}': #{e.message}"
          # Try to close the context in case of error
          begin
            model.close_active
          rescue
            # Ignore errors when closing
          end
        end
        
      when Sketchup::ComponentInstance
        # Enter the component's edit context
        comp_name = entity.definition.name || "Unnamed Component"
        puts "Entering component: #{comp_name}"
        
        begin
          # Edit the component (equivalent to double-clicking)
          model.edit_entity(entity)
          
          # Process entities within this component context
          new_context_path = context_path + [comp_name]
          count = process_entities_with_context(entity.definition.entities, new_context_path, count)
          
          # Exit the component context
          model.close_active
          puts "Exited component: #{comp_name}"
          
        rescue => e
          puts "Error processing component '#{comp_name}': #{e.message}"
          # Try to close the context in case of error
          begin
            model.close_active
          rescue
            # Ignore errors when closing
          end
        end
      end
    end
    
    return count
  end
  
  def self.convert_image_in_context(image, context_desc)
    begin
      # Get image properties before exploding
      image_name = image.name || "Converted_Image"
      image_material = image.material
      
      puts "  Converting image: #{image_name} in context: #{context_desc}"
      puts "    Size: #{image.width}\" x #{image.height}\""
      puts "    Material: #{image_material ? image_material.name : 'None'}"
      
      # Explode the image within the current edit context
      exploded_entities = image.explode
      
      if exploded_entities && !exploded_entities.empty?
        puts "    Exploded into #{exploded_entities.length} entities"
        
        # Verify we created faces
        face_count = 0
        exploded_entities.each do |exploded_entity|
          if exploded_entity.is_a?(Sketchup::Face)
            face_count += 1
            # Ensure the face has the correct material applied
            if image_material
              exploded_entity.material = image_material
            end
            puts "    Created face with material: #{exploded_entity.material ? exploded_entity.material.name : 'None'}"
          end
        end
        
        if face_count > 0
          puts "    SUCCESS: Created #{face_count} face(s)"
          return true
        else
          puts "    WARNING: No faces created from exploded image"
          return false
        end
        
      else
        puts "    WARNING: Explode operation returned no entities"
        return false
      end
      
    rescue => e
      puts "    ERROR converting image '#{image_name}': #{e.message}"
      return false
    end
  end
  
  # Utility method to count images without converting (for preview)
  def self.count_images
    model = Sketchup.active_model
    
    # Clear any existing edit contexts first
    while model.active_path && model.active_path.length > 0
      model.close_active
    end
    
    count = count_entities_with_context(model.entities, [])
    
    # Make sure we're back to the root context
    while model.active_path && model.active_path.length > 0
      model.close_active
    end
    
    if count > 0
      UI.messagebox("Found #{count} Image entit#{count == 1 ? 'y' : 'ies'} in the model.")
      puts "Found #{count} images in the model."
    else
      UI.messagebox("No Image entities found in the model.")
      puts "No images found in the model."
    end
    
    return count
  end
  
  def self.count_entities_with_context(entities, context_path, count = 0)
    model = Sketchup.active_model
    
    # Build context description for logging
    context_desc = context_path.empty? ? "Root" : context_path.join(" > ")
    
    # Count images at this level
    entities.each do |entity|
      if entity.is_a?(Sketchup::Image)
        count += 1
        puts "Found image: #{entity.name || 'Unnamed'} in context: #{context_desc}"
      end
    end
    
    # Process nested containers
    entities.each do |entity|
      case entity
      when Sketchup::Group
        group_name = entity.name || "Unnamed Group"
        
        begin
          # Edit the group to access its contents
          model.edit_entity(entity)
          
          # Count entities within this group context
          new_context_path = context_path + [group_name]
          count = count_entities_with_context(entity.entities, new_context_path, count)
          
          # Exit the group context
          model.close_active
          
        rescue => e
          puts "Error accessing group '#{group_name}': #{e.message}"
          # Try to close the context in case of error
          begin
            model.close_active
          rescue
            # Ignore errors when closing
          end
        end
        
      when Sketchup::ComponentInstance
        comp_name = entity.definition.name || "Unnamed Component"
        
        begin
          # Edit the component to access its contents
          model.edit_entity(entity)
          
          # Count entities within this component context
          new_context_path = context_path + [comp_name]
          count = count_entities_with_context(entity.definition.entities, new_context_path, count)
          
          # Exit the component context
          model.close_active
          
        rescue => e
          puts "Error accessing component '#{comp_name}': #{e.message}"
          # Try to close the context in case of error
          begin
            model.close_active
          rescue
            # Ignore errors when closing
          end
        end
      end
    end
    
    return count
  end
  
  # Debug method to show current edit context
  def self.debug_context
    model = Sketchup.active_model
    if model.active_path && model.active_path.length > 0
      puts "Current edit context depth: #{model.active_path.length}"
      model.active_path.each_with_index do |entity, index|
        puts "  Level #{index}: #{entity.class} - #{entity.name || 'Unnamed'}"
      end
    else
      puts "Currently in root context"
    end
  end
  
end
