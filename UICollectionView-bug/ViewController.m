//
//  ViewController.m
//  UICollectionView-bug
//
//  Created by Alexey Storozhev on 22/01/16.
//  Copyright © 2016 Aleksey Storozhev. All rights reserved.
//

#import "ViewController.h"
#import "UICollectionViewTreeLayout.h"

const CGSize kChildSize = { 100.f, 100.f };

static Node *ChildNode() {
    Node *node = [Node new];
    node.size = kChildSize;
    return node;
}

static Node *RandomNodeWithChildrenRange(NSRange range) {

    NSMutableArray *children = [NSMutableArray array];
    const NSUInteger childrenCount = range.location + (range.length > 0 ? (arc4random() % range.length) : 0);
    
    const CGFloat inset = 10.f;
    CGFloat x = inset;
    CGFloat h = 0;
    for (NSUInteger i=0; i<childrenCount; i++) {
        Node *cNode = ChildNode();

        [children addObject:[NodeChild childWithNode:cNode atPoint:CGPointMake(x, inset)]];
        
        h = MAX(h, cNode.size.height);
        x += cNode.size.width + inset;
    }
    
    Node *node = [Node new];
    node.size = CGSizeMake(x, h + inset*2);
    node.children = children;
    return node;
}

static Node *RandomRootNode()
{
    return RandomNodeWithChildrenRange(NSMakeRange(arc4random()%4, arc4random()%4));
}

@interface TestCell : UICollectionViewCell
@end

@implementation TestCell
@end


@interface TestSupplementaryView : UICollectionReusableView
@end

@implementation TestSupplementaryView
@end

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateTreeLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) NSMutableArray *section;
@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItems = @[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionInsert:)],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(actionDelete:)],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionReset:)],
        ];

        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.navigationItem.titleView = switchView;
        self.switchView = switchView;
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.section = [NSMutableArray array];
    }
    return self;
}

- (void)loadView {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewTreeLayout new]];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    [collectionView registerClass:[TestCell class] forCellWithReuseIdentifier:@"cell"];
    [collectionView registerClass:[TestSupplementaryView class] forSupplementaryViewOfKind:@"kind1" withReuseIdentifier:@"sup1"];
    [collectionView registerClass:[TestSupplementaryView class] forSupplementaryViewOfKind:@"kind2" withReuseIdentifier:@"sup2"];

    self.view = collectionView;
    self.collectionView = collectionView;
}

#pragma mark - Actions

- (void)actionInsert:(id)sender {
    
    [_section insertObject:RandomRootNode() atIndex:1];
    [_section insertObject:RandomRootNode() atIndex:2];
    
    if ([self.switchView isOn]) {
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:@[
                                                           [NSIndexPath indexPathForItem:1 inSection:0],
                                                           [NSIndexPath indexPathForItem:2 inSection:0]
                                                           ]];
        } completion:^(BOOL finished) {}];
    } else {
        [self.collectionView reloadData];
    }
}

- (void)actionDelete:(id)sender {
    [_section removeObjectAtIndex:1];
    [_section removeObjectAtIndex:2];
    
    if ([self.switchView isOn]) {
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[
                                                           [NSIndexPath indexPathForItem:1 inSection:0],
                                                           [NSIndexPath indexPathForItem:3 inSection:0]
                                                           ]];
        } completion:^(BOOL finished) {}];
    } else {
        [self.collectionView reloadData];
    }
}

- (void)actionReset:(id)sender {
    [_section removeAllObjects];
    
    for (NSUInteger i=0; i<4; i++) {
        [_section insertObject:RandomRootNode() atIndex:0];
    }

    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.section count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6f];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    NSString *reuseIdentifier = nil;
    UIColor *color = nil;
    
    if ([kind isEqualToString:@"kind1"]) {
        reuseIdentifier = @"sup1";
        color = [UIColor greenColor];
    } else if ([kind isEqualToString:@"kind2"]) {
        reuseIdentifier = @"sup2";
        color = [UIColor magentaColor];
    }
    
    TestSupplementaryView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    view.backgroundColor = [color colorWithAlphaComponent:1.f - ([indexPath length]-2) * 0.2f];
    return view;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDelegateTreeLayout

- (Node *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewTreeLayout *)layout nodeForIndexPath:(NSIndexPath *)indexPath {
    return self.section[indexPath.row];
}

@end
