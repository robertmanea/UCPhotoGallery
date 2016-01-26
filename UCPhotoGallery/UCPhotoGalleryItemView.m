#import "UCPhotoGalleryItemView.h"
#import <AVFoundation/AVFoundation.h>
#import <WebImage/SDImageCache.h>
#import <WebImage/UIImageView+WebCache.h>

CGFloat aspectRatio(CGSize size);
CGFloat aspectRatio(CGSize size) {
    return size.width / size.height;
};

@interface UCPhotoGalleryItemView () <UIScrollViewDelegate>
@end

@implementation UCPhotoGalleryItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;

        self.imageView = ({
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeCenter;
            imageView.autoresizingMask = UIViewAutoresizingNone;
            [self addSubview:imageView];
            imageView;
        });

        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(viewDoubleTapped:)];
        recognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:recognizer];
    }

    return self;
}


- (void)setUrl:(NSURL *)url {
    _url = url;
    if (!url) {
        return;
    }

    __weak typeof(self) weakself = self;
    [self.imageView sd_setImageWithURL:url
                             completed:^(UIImage *image, __unused NSError *error,
                                         __unused SDImageCacheType cacheType, __unused NSURL *imageURL)
     {
         [weakself.imageCache storeImage:image forKey:url.absoluteString];
         [weakself displayImage];
         if ([weakself.galleryItemDelegate respondsToSelector:@selector(imageLoadedForGalleryItem:)]) {
             [weakself.galleryItemDelegate imageLoadedForGalleryItem:weakself];
         }
     }];
}

- (void)viewDoubleTapped:(UITapGestureRecognizer *)recognizer {
    if (self.zoomScale != self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        // Zoom in to twice the size
        CGPoint touchPoint = [recognizer locationInView:self.imageView];
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize / 2, touchPoint.y - ysize / 2, xsize, ysize)
                animated:YES];
    }
}

- (void)prepareForReuse {
    self.url = nil;
    [self.imageView sd_cancelCurrentImageLoad];
}

- (void)displayImage {
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeZero;

    // Get image from browser as it handles ordering of fetching
    UIImage *img = self.imageView.image;
    if (img) {
        // Set image
        self.imageView.hidden = NO;

        // Setup photo frame
        if (self.imageView.contentMode == UIViewContentModeScaleAspectFill) {
            self.imageView.frame = [self aspectFillFrameForImage:img];
        } else {
            CGRect photoImageViewFrame;
            photoImageViewFrame.origin = CGPointZero;
            photoImageViewFrame.size = img.size;
            self.imageView.frame = photoImageViewFrame;
        }

        self.contentSize = self.imageView.bounds.size;

        // Set zoom to minimum zoom
        [self setMaxMinZoomScalesForCurrentBounds];
    }

    [self setNeedsLayout];
}

- (CGRect)aspectFillFrameForImage:(UIImage *)image {
    if (!image || CGSizeEqualToSize(image.size, CGSizeZero)) {
        return CGRectZero;
    }

    CGRect ret = CGRectZero;
    CGFloat selfAspectRatio = aspectRatio(self.bounds.size);
    CGFloat imageAspectRatio = aspectRatio(image.size);
    if (selfAspectRatio > imageAspectRatio) {
        // self wider than image
        ret.size.width = self.bounds.size.width;
        ret.size.height = ret.size.width / imageAspectRatio;
        ret.origin.y = floor((self.bounds.size.height - ret.size.height) / 2);
    } else {
        // image wider than self
        ret.size.height = self.bounds.size.height;
        ret.size.width = ret.size.height * imageAspectRatio;
        ret.origin.x = floor((self.bounds.size.width - ret.size.width) / 2);
    }

    return ret;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect imageViewFrame;

    if (self.imageView.contentMode == UIViewContentModeScaleAspectFill) {
        imageViewFrame = [self aspectFillFrameForImage:self.imageView.image];
    } else {
        // Center the image as it becomes smaller than the size of the screen
        CGSize boundsSize = self.bounds.size;
        imageViewFrame = self.imageView.frame;

        // Horizontally
        if (imageViewFrame.size.width < boundsSize.width) {
            imageViewFrame.origin.x = floor((boundsSize.width - imageViewFrame.size.width) / 2.0f);
        } else {
            imageViewFrame.origin.x = 0;
        }

        // Vertically
        if (imageViewFrame.size.height < boundsSize.height) {
            imageViewFrame.origin.y = floor((boundsSize.height - imageViewFrame.size.height) / 2.0f);
        } else {
            imageViewFrame.origin.y = 0;
        }
    }

    if (!CGRectEqualToRect(self.imageView.frame, imageViewFrame)) {
        self.imageView.frame = imageViewFrame;
    }
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    // Reset
    if (!self.imageView.image) {
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.zoomScale = 1;
        return;
    }

    if (self.imageView.contentMode == UIViewContentModeScaleAspectFill) {
        self.zoomScale = 1;
        self.imageView.frame = [self aspectFillFrameForImage:self.imageView.image];
        return;
    }

    // Reset position
    self.imageView.frame = (CGRect) {CGPointZero, self.imageView.frame.size};

    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;

    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale;
    if (self.imageView.contentMode == UIViewContentModeScaleAspectFill) {
        minScale = MAX(xScale, yScale); // use maximum of these to allow the image to completely cover self
    } else {
        minScale = MIN(xScale, yScale); // use minimum of these to allow the image to become fully visible
    }

    // Calculate Max
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }

    // Image is smaller than screen so no zooming!
    if (self.imageView.contentMode == UIViewContentModeScaleAspectFill && xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }

    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;

    // Start fully zoomed out
    self.zoomScale = minScale;

    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
    self.scrollEnabled = NO;

    // Layout
    [self layoutSubviews];
}

- (CGRect)imageFrame {
    return AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size, self.imageView.bounds);
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(__unused UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(__unused UIScrollView *)scrollView withView:(__unused UIView *)view {
    self.scrollEnabled = YES;
}

- (void)scrollViewDidZoom:(__unused UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    if ([self.galleryItemDelegate respondsToSelector:@selector(galleryItemDidZoom:)]) {
        [self.galleryItemDelegate galleryItemDidZoom:self];
    }
}

@end
