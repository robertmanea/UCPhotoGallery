# UCPhotoGallery

[![CI Status](http://img.shields.io/travis/UrbanCompass/UCPhotoGallery.svg?style=flat)](https://travis-ci.org/UrbanCompass/UCPhotoGallery)
[![Version](https://img.shields.io/cocoapods/v/UCPhotoGallery.svg?style=flat)](http://cocoadocs.org/docsets/UCPhotoGallery)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/UCPhotoGallery.svg?style=flat)](http://cocoadocs.org/docsets/UCPhotoGallery)
[![Platform](https://img.shields.io/cocoapods/p/UCPhotoGallery.svg?style=flat)](http://cocoadocs.org/docsets/UCPhotoGallery)

This project provides a drop-in image gallery UI component with a simple interface, as well as a full-screen photo viewer with a drag-to-dismis interaction.

## Usage

### Option 1: Embed the UCPhotoGallery's view in your view 
1. Instantiate a `UCPhotoGallery`
2. Add it as a child view controller
3. Add its subview to your view

See the "Embedded" tab in the sample app (backed by the `GalleryContainerViewController`) for an example.

### Option 2: Transition to a full-screen UCPhotoGallery from your image
This option is a little more invovled, but allows you to display non-full-screen images however you would like and smoothly transition to a full-screen gallery.
1. Create a `UCPhotoGalleryFullscreenTransitionController` and set `isFullscreen` to `YES`
2. Implement the `UIViewControllerTransitioningDelegate` protocol, returning the transition controller created in step 1
3. When transitioning to full-screen mode, create a `UCPhotoGalleryController`, set its `transitioningDelegate` to your view controller, and set its `modalPresentationStyle` to `UIModalPresentationCustom`
4. Any time the gallery's current page changes, you'll need to update your images UI to ensure that a smooth transition back is possible. You will need to keep `presentFromRect` and `transitionImage` in sync (see `PhotosCollectionViewController.m` in the example project)

See the "Transition" tab in the sample app (backed by the `PhotosCollectionViewController` class) for an example.

### UCGalleryViewDataSource
UCGalleryViewDataSource has a very simple, one-method interface: `imageURLsForGalleryView:`. Simply provide an `NSArray` of image URLs and the gallery can do the rest.

### UCGalleryViewDelegate


## Running the example project

```shell
$ git clone https://github.com/UrbanCompass/UCPhotoGallery.git
$ cd UCPhotoGallery
$ open UCPhotoGallery.xcworkspace
```

Once in Xcode, ensure the target is `UCPhotoGalleryExample`, build, and run.

The same project is capable of demonstrating both the `UCPhotoGalleryViewController` and the `UCPhotosViewController`. Switching between them can be done by commenting/uncommenting the appropriate lines in `ViewController.m`'s `viewDidLoad` function. 
