#import "PhotoCell.h"
@import WebImage;

@interface PhotoCell ()
@end

@implementation PhotoCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
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

- (UIImage *)image {
    return self.photoImageView.image;
}

@end
