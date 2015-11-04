# UCPhotoGallery

[![CI Status](http://img.shields.io/travis/UrbanCompass/UCPhotoGallery.svg?style=flat)](https://travis-ci.org/UrbanCompass/UCPhotoGallery)
[![Version](https://img.shields.io/cocoapods/v/UCPhotoGallery.svg?style=flat)](http://cocoadocs.org/docsets/UCPhotoGallery)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/UCPhotoGallery.svg?style=flat)](http://cocoadocs.org/docsets/UCPhotoGallery)
[![Platform](https://img.shields.io/cocoapods/p/UCPhotoGallery.svg?style=flat)](http://cocoadocs.org/docsets/UCPhotoGallery)

This project aims to create a drop-in image gallery UI component with a simple interface.

There are two view controllers (`UCPhotoGalleryViewController`, which provides a horizontal gallery,  and `UCPhotosViewController`, which provides a vertical gallery) that lay out photos in different ways. Both of these interface with a `UCGalleryViewDataSource` and a `UCGalleryViewDelegate` to turn a simple array of `NSURL` objects into a gallery of image views. Both of these also provide an animated transition to a full-screen `UCPhotoGalleryViewController`.

## Usage
To run the example project, clone the repo and run `pod install`.



1. Create an instance of whichever controller you would like to use
2. Add it as a child view controller of the owning view
3. Add its view to the parent view controller's view
4. Implement `UCGalleryViewDataSource` (currently just the `imageURLsForGalleryView:` function)
5. That's it!

## Running the example project

```shell
$ git clone https://github.com/UrbanCompass/UCPhotoGallery.git
$ cd UCPhotoGallery
$ pod install
$ open UCPhotoGallery.xcworkspace
```

Once in Xcode, ensure the target is `UCPhotoGalleryExample`, build, and run.

The same project is capable of demonstrating both the `UCPhotoGalleryViewController` and the `UCPhotosViewController`. Switching between them can be done by commenting/uncommenting the appropriate lines in `ViewController.m`'s `viewDidLoad` function. 
