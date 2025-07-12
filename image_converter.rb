# image_converter.rb
# Main loader file for Image to Geometry Converter Plugin

require 'sketchup.rb'

# Check SketchUp version compatibility
if Sketchup.version.to_i < 21
  UI.messagebox("Image Converter requires SketchUp 2021 or newer.")
else
  # Load the core functionality
  require File.join(File.dirname(__FILE__), 'image_converter', 'image_converter_core.rb')
  
  # Add menu items only if not already loaded
  unless file_loaded?(__FILE__)
    
    # Add main menu items
    tools_menu = UI.menu("Tools")
    
    # Add a submenu for organization (optional)
    converter_menu = tools_menu.add_submenu("Image Converter")
    
    converter_menu.add_item("Convert Images to Geometry") {
      ImageToGeometryConverter.convert_images
    }
    
    converter_menu.add_separator
    
    converter_menu.add_item("Count Images") {
      ImageToGeometryConverter.count_images
    }
    
    converter_menu.add_item("Debug Context") {
      ImageToGeometryConverter.debug_context
    }
    
    # Optional: Add to context menu (right-click menu)
    UI.add_context_menu_handler do |context_menu|
      context_menu.add_separator
      context_menu.add_item("Convert Images to Geometry") {
        ImageToGeometryConverter.convert_images
      }
    end
    
    # Optional: Add toolbar (more advanced)
    # toolbar = UI::Toolbar.new("Image Converter")
    # cmd = UI::Command.new("Convert Images") { ImageToGeometryConverter.convert_images }
    # cmd.tooltip = "Convert all Image entities to geometry"
    # cmd.status_bar_text = "Convert Image entities to faces with textures"
    # toolbar.add_item(cmd)
    # toolbar.show
    
    puts "Image Converter plugin loaded successfully."
    
  end
  
  file_loaded(__FILE__)
end
