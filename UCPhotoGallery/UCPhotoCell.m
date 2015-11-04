#import "UCPhotoCell.h"
#import "UIImageView+WebCache.h"
@import AVFoundation;

@interface UCPhotoCell ()
@property (nonatomic) UIImageView *photoImageView;
@end

@implementation UCPhotoCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.photoImageView = ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self.contentView addSubview:imageView];
            imageView;
        });
    }

    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.url = nil;
    [self.photoImageView sd_cancelCurrentImageLoad];
    self.photoImageView.image = nil;
    self.photoImageView.frame = self.contentView.bounds;
}

- (CGRect)imageFrame {
    return AVMakeRectWithAspectRatioInsideRect(self.photoImageView.image.size, self.photoImageView.bounds);
}

- (UIImage *)image {
    return self.photoImageView.image;
}

- (void)setUrl:(NSURL *)url {
    if ([url isEqual:_url]) {
        return;
    }

    _url = url;
    [self.photoImageView sd_setImageWithURL:url
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      self.photoImageView.image = image;
                                      if ([self.delegate respondsToSelector:@selector(imageLoadedForPhotoCell:)]) {
                                          [self.delegate imageLoadedForPhotoCell:self];
                                      }
    }];
}

@end
