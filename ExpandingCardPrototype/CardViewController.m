//
//  CardViewController.m
//  ExpandingCardPrototype
//
//  Created by Brian Sachetta on 3/18/16.
//  Copyright © 2016 IntrepidPursuits. All rights reserved.
//

#import "CardViewController.h"

typedef NS_ENUM(NSUInteger, ConstraintDirection) {
    ConstraintDirectionTop,
    ConstraintDirectionLeft,
    ConstraintDirectionBottom,
    ConstraintDirectionRight,
};

static CGFloat const kCardPaddingPercentTop = 0.1f;
static CGFloat const kCardPaddingPercentSide = 0.1;
static CGFloat const kTableViewCellHeight = 100.0f;
static CGFloat const kCardCornerRadius = 10.0f;
static NSString * const kTableCellReuseId = @"TableCellReuseId";

@interface CardViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bigContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *bigScrollView;
@property (weak, nonatomic) IBOutlet UIView *smallContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smallScrollViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smallScrollViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smallScrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smallScrollViewRightConstraint;

@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBigScrollView];
    [self setupSmallContainerView];
    [self setupTableView];
}

- (void)setupBigScrollView {
    CGFloat height = [self.tableView numberOfRowsInSection:0] * kTableViewCellHeight + ([self maxYOffsetBeforeScrolling]);
    self.bigScrollView.contentSize = CGSizeMake(self.bigScrollView.contentSize.width, height);
}

- (void)setupSmallContainerView {
    [self updateCardViewConstraintsForOffset:0.0f];
    self.smallContainerView.layer.cornerRadius = kCardCornerRadius;
    self.smallContainerView.clipsToBounds = YES;
}

- (void)setupTableView {
    [self.tableView removeGestureRecognizer:self.tableView.panGestureRecognizer];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableCellReuseId];
}

#pragma mark - Changing Table Placement

- (void)expandTableViewFully {
    [self updateCardViewConstraintsForOffset:[self offsetForExpandedTableView].y];
}

- (void)collapseTableViewFully {
    [self updateCardViewConstraintsForOffset:[self offsetForCollapsedTableView].y];
}

- (CGPoint)offsetForExpandedTableView {
    return CGPointMake(0.0f, [self maxYOffsetBeforeScrolling] + 1);
}

- (CGPoint)offsetForCollapsedTableView {
    return CGPointMake(0.0f, 0.0f);
}

- (void)updateCardViewConstraintsForOffset:(CGFloat)offset {
    self.smallScrollViewTopConstraint.constant = [self constraintSizeForOffset:offset constraintDirection:ConstraintDirectionTop];
    self.smallScrollViewLeftConstraint.constant = [self constraintSizeForOffset:offset constraintDirection:ConstraintDirectionLeft];
    self.smallScrollViewBottomConstraint.constant = [self constraintSizeForOffset:offset constraintDirection:ConstraintDirectionBottom];
    self.smallScrollViewRightConstraint.constant = [self constraintSizeForOffset:offset constraintDirection:ConstraintDirectionRight];
}

#pragma mark - UIScrollViewDelegate / Helpers

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.bigScrollView) {
        CGFloat maxYOffsetForSmallScrollView = [self maxYOffsetBeforeScrolling];
        CGFloat yOffset = scrollView.contentOffset.y;
        // the table view has not yet expanded all the way out
        // so set the table view offest to 0 and update its edge constraints
        if (yOffset <= maxYOffsetForSmallScrollView) {
            [self updateCardViewConstraintsForOffset:yOffset];
            self.tableView.contentOffset = CGPointMake(0, 0);
            if (self.smallContainerView.layer.cornerRadius != kCardCornerRadius) {
                self.smallContainerView.layer.cornerRadius = kCardCornerRadius;
            }
        }
        else {
            if (self.smallScrollViewTopConstraint.constant != 0.0f) {
                [self expandTableViewFully];
            }
            self.tableView.contentOffset = CGPointMake(0, (yOffset - maxYOffsetForSmallScrollView));
            if (self.smallContainerView.layer.cornerRadius != 0.0f) {
                self.smallContainerView.layer.cornerRadius = 0.0f;
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat scrollDistanceBeforeInFullScreenMode = [self maxYOffsetBeforeScrolling];
    if (targetContentOffset->y < [self maxYOffsetBeforeScrolling]) {
        if (targetContentOffset->y < scrollDistanceBeforeInFullScreenMode / 2.0f) {
            *targetContentOffset = [self offsetForCollapsedTableView];
        } else {
            *targetContentOffset = [self offsetForExpandedTableView];
        }
    }
}

#pragma mark - Size Helpers

- (CGFloat)constraintSizeForOffset:(CGFloat)offset constraintDirection:(ConstraintDirection)constraintDirection {
    CGSize sizeOfScreen = self.view.bounds.size;
    CGFloat scrollDistanceBeforeInFullScreenMode = [self maxYOffsetBeforeScrolling];
    CGFloat scalingFactor = MIN(1, (scrollDistanceBeforeInFullScreenMode - offset) / scrollDistanceBeforeInFullScreenMode);
    CGFloat originalConstraintSize;
    if (constraintDirection == ConstraintDirectionTop || constraintDirection == ConstraintDirectionBottom) {
        originalConstraintSize = sizeOfScreen.height * kCardPaddingPercentTop;
    } else {
        originalConstraintSize = sizeOfScreen.width * kCardPaddingPercentSide;
    }
    return MAX(0, originalConstraintSize * scalingFactor);
}

- (CGFloat)maxYOffsetBeforeScrolling {
    return self.view.bounds.size.height * kCardPaddingPercentTop;
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableCellReuseId forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Row Num: %ld", (long)indexPath.row + 1];
    cell.contentView.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewCellHeight;
}

@end
