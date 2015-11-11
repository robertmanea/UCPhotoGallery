#import "UCPhotoGalleryItemView.h"
#import <AVFoundation/AVFoundation.h>
#import <WebImage/UIImageView+WebCache.h>

@interface UCPhotoGalleryItemView () <UIScrollViewDelegate>
@end

@implementation UCPhotoGalleryItemView

+ (NSString *)reuseId {
    static NSString *reuseId = @"UCPhotoGalleryItemView";
    return reuseId;
}

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
    [self.imageView sd_setImageWithURL:url
                             completed:^(__unused UIImage *image, __unused NSError *error,
                                         __unused SDImageCacheType cacheType, __unused NSURL *imageURL)
     {
         [self displayImage];
         if ([self.galleryItemDelegate respondsToSelector:@selector(imageLoadedForGalleryItem:)]) {
             [self.galleryItemDelegate imageLoadedForGalleryItem:self];
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
    self.contentSize = CGSizeMake(0, 0);

    // Get image from browser as it handles ordering of fetching
    UIImage *img = self.imageView.image;
    if (img) {
        // Set image
        self.imageView.hidden = NO;

        // Setup photo frame
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = img.size;
        self.imageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;

        // Set zoom to minimum zoom
        [self setMaxMinZoomScalesForCurrentBounds];
    }

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;

    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0f);
    } else {
        frameToCenter.origin.x = 0;
    }

    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0f);
    } else {
        frameToCenter.origin.y = 0;
    }

    // Center
    if (!CGRectEqualToRect(self.imageView.frame, frameToCenter)) {
        self.imageView.frame = frameToCenter;
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

    // Reset position
    self.imageView.frame = (CGRect) {CGPointZero, self.imageView.frame.size};

    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;

    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible

    // Calculate Max
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }

    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
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
