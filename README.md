# UCPhotoGallery

[![CI Status](http://img.shields.io/travis/UrbanCompass/UCPhotoGallery.svg?style=flat)](https://travis-ci.org/UrbanCompass/UCPhotoGallery)
[![Version](https://img.shields.io/cocoapods/v/UCPhotoGallery.svg?style=flat)](http://cocoadocs.org/docsets/UCPhotoGallery)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/UCPhotoGallery.svg?style=flat)](http://cocoadocs.org/docsets/UCPhotoGallery)
[![Platform](https://img.shields.io/cocoapods/p/UCPhotoGallery.svg?style=flat)](http://cocoadocs.org/docsets/UCPhotoGallery)

This project provides a drop-in image gallery UI component with a simple interface, as well as a full-screen photo viewer with a drag-to-dismis interaction.

## Installation

### CocoaPods

This project is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "UCPhotoGallery"

### Carthage

To integrate UCPhotoGallery into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "UrbanCompass/UCPhotoGallery" "carthage"
```

## Usage

### Option 1: Embed the UCPhotoGallery's view in your view
1. Instantiate a `UCPhotoGalleryViewController`
2. Add it as a child view controller
3. Add its subview to your view

```objc
UCPhotoGalleryViewController *galleryVC = [UCPhotoGalleryViewController new];
galleryVC.dataSource = self;
[self addChildViewController:self.galleryVC];
[self.view addSubview:self.galleryVC.view];
```
See the "Embedded" tab in the sample app (code in `GalleryContainerViewController.m`) for a working example.

### Option 2: Transition to a full-screen UCPhotoGallery from your image
This option is a little more invovled, but allows you to display non-full-screen images however you would like and smoothly transition to a full-screen gallery.

1. Create a `UCPhotoGalleryFullscreenTransitionController`
2. Implement the `UIViewControllerTransitioningDelegate` protocol, returning the transition controller created in step 1
3. When you want to transition to the full-screen gallery, create a `UCPhotoGalleryViewController`, set `isFullscreen` to `YES` and its `transitioningDelegate` to your view controller, and set its `modalPresentationStyle` to `UIModalPresentationCustom`
4. Before presenting the full-screen gallery, set the transition controller's `presentFromRect` and `transitionImage` properties. `presentFromRect` is the selected image's frame relative to the screen and `transitionImage` is the image itself.
5. Call `presentViewController:animated:completed:` to present the full-screen gallery controller created in step 3.
4. When you're ready to transition to your view controller, update the trasition controller to reflect gallery's page changes wi, you'll need to update your images UI to ensure that a smooth transition back is possible. You will need to keepin sync (see `PhotosCollectionViewController.m` in the example project)

See the "Transition" tab in the sample app (code in `PhotosCollectionViewController.m`) for a working example.

### UCGalleryViewDataSource
`UCGalleryViewDataSource` has a very simple, one-method interface: `imageURLsForGalleryView:`. Simply provide an `NSArray` of image URLs and the gallery can do the rest.

### UCGalleryViewDelegate
`UCGalleryViewDelegate` provides a handful of optional functions that allow the delegate to customize the gallery controller and respond to its actions.

## Other notes
`UCPhotoGalleryViewController` supports two different ways of displaying images: aspect fit and aspect fill. Aspect fit is the default, but this can be set a) for all images by setting `imageScalingMode` to either `UCImageScalingModeFit` or `UCImageScalingModeFill` b) for individual images by implementing `galleryViewController:scalingModeForImageAtIndex:` on your `UCGalleryViewDelegate`.

## Running the example project

```shell
$ git clone https://github.com/UrbanCompass/UCPhotoGallery.git
$ cd UCPhotoGallery
$ open UCPhotoGallery.xcworkspace
```

Once in Xcode, ensure the target is `UCPhotoGalleryExample`, build, and run.

## License

This project is available under the MIT license. See the LICENSE file for more info.
