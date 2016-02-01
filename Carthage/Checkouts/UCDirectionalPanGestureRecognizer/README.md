# UCDirectionalPanGestureRecognizer
A gesture recognizer that detects panning in one dimension. Taken from [this StackOverflow answer](http://stackoverflow.com/questions/7100884/uipangesturerecognizer-only-vertical-or-horizontal) and adapted to Objective C.

## Installation

This project is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "UCDirectionalPanGestureRecognizer"

## Usage

```objc
    self.panRecognizer = [[UCDirectionalPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(viewPanned:)];
    self.panRecognizer.direction = UCGestureRecognizerDirectionVertical;
    [self.view addGestureRecognizer:self.panRecognizer];
```

## Running the example project

```shell
$ git clone https://github.com/UrbanCompass/UCDirectionalPanGestureRecognizer.git
$ cd UCDirectionalPanGestureRecognizer
$ open UCDirectionalPanGestureRecognizer.xcproj
```

Once in Xcode, ensure the target is `UCDirectionalPanGestureRecognizerExample`, build, and run.

## License

This project is available under the MIT license. See the LICENSE file for more info.
