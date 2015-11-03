# UCPhotoGallery
This project aims to create a drop-in image gallery UI component with a simple interface.

There are two view controllers (`UCPhotoGalleryViewController`, which provides a horizontal gallery,  and `UCPhotosViewController`, which provides a vertical gallery) that lay out photos in different ways. Both of these interface with a `UCGalleryViewDataSource` and a `UCGalleryViewDelegate` to turn a simple array of `NSURL` objects into a gallery of image views. Both of these also provide an animated transition to a full-screen `UCPhotoGalleryViewController`.

## Usage
1. Create an instance of whichever controller you would like to use
2. Add it as a child view controller of the owning view
3. Add its view to the parent view controller's view
4. Implement `UCGalleryViewDataSource` (currently just the `imageURLsForGalleryView:` function)
5. That's it!

## Running the example project
After cloning this repository…

1. `cd UCPhotoGallery`
2. `pod install`
3. Open `UCPhotoGallery.xcworkspace`
4. Ensure the target is `UCPhotoGalleryExample`
5. Build and run

Switching between the `UCPhotoGalleryViewController` and the `UCPhotosViewController` can be done by commenting/uncommenting the appropriate lines in `ViewController.m`'s `viewDidLoad` function. 
