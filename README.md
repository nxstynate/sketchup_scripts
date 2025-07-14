# Image to Geometry Converter

This SketchUp plugin converts `Image` entities into `Face` entities with the corresponding texture applied. This is useful for situations where you need to manipulate the geometry of an image or for rendering applications that do not properly handle SketchUp's `Image` entities.

## Installation

1.  Open SketchUp.
2.  Go to `Window` > `Extension Manager`.
3.  Click the `Install Extension` button.
4.  Navigate to the `image_converter.rbz` file and select it.
5.  When prompted, confirm that you want to install the extension.

## Usage

Once installed, the plugin will add a new submenu under the `Tools` menu called `Image Converter`.

*   **Convert Images to Geometry**: This is the main function of the plugin. It will recursively find all `Image` entities in your model, including those nested within groups and components, and convert them into `Face` entities.
*   **Count Images**: This will count and report the number of `Image` entities in your model.
*   **Run Diagnostics**: This will print out information about the model to the Ruby Console, including the number of images, faces with textures, groups, and components.

The "Convert Images to Geometry" option is also available in the context menu when you right-click.

## Features

*   **Recursive Conversion**: The plugin will search through the entire model, including nested groups and components, to find and convert all `Image` entities.
*   **Progress Bar**: For models with many images, a progress bar will be displayed in the status bar.
*   **Error Handling**: The plugin includes error handling to prevent issues during the conversion process.

## Diagnostics

The `Run Diagnostics` tool is useful for debugging and understanding the contents of your model. It provides a summary of:

*   `Sketchup::Image` entities
*   Faces with textures
*   Groups
*   Component Instances

The detailed output is printed to the Ruby Console (`Window` > `Ruby Console`).

## Compatibility

This plugin is compatible with SketchUp 2021 and newer.
