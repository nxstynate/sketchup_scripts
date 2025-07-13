### Method 1: Ruby Console (Recommended for testing)

1. Open SketchUp and go to `Window > Ruby Console`
2. Copy and paste the entire script into the console
3. Run the conversion by typing:
   ```ruby
   ImageToGeometryConverter.convert_images
   ```

### Method 2: As a Plugin

1. Save the script as a `.rb` file (e.g., `image_converter.rb`)
2. Place it in your SketchUp Plugins folder
3. Uncomment the menu section at the bottom of the script
4. Restart SketchUp - you'll see new menu items under `Tools`

## Key Features & Nuances

### What the Script Does:

1. **Recursively scans** the entire model, including nested groups and components
2. **Finds all `Sketchup::Image` entities** regardless of nesting level
3. **Explodes each image** using SketchUp's built-in `explode` method
4. **Preserves materials** - the image texture becomes a proper material applied to the resulting face
5. **Provides undo support** - the entire operation can be undone with Ctrl+Z
6. **Logs progress** to the Ruby Console for debugging

### Important Nuances:

**1. Component Definitions vs Instances**

- The script processes component definitions, not instances
- This means if you have multiple instances of a component containing an image, the image will be converted once in the definition, affecting all instances

**2. Material Handling**

- When an image is exploded, SketchUp automatically creates a material from the image
- The script ensures this material is properly applied to the resulting face

**3. Coordinate Systems**

- Images maintain their position and orientation after conversion
- The exploded face will be in the same location as the original image

**4. Error Handling**

- The script includes comprehensive error handling
- If any part fails, the operation is aborted and can be undone

**5. Memory Considerations**

- Large images or models with many images may take time to process
- The script provides progress feedback in the Ruby Console

### Testing Before Full Conversion:

You can preview how many images will be converted using:

```ruby
ImageToGeometryConverter.count_images
```

### Blender Compatibility:

After running this script, your SketchUp model will have:

- Actual geometry (faces) instead of Image entities
- Proper materials with textures applied
- Better compatibility with Blender importers

The converted faces should now be properly recognized by Blender's SketchUp importers, solving your workflow issue.
