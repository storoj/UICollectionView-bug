//
//  UICollectionViewTreeLayout.h
//  UICollectionView-bug
//
//  Created by Alexey Storozhev on 22/01/16.
//  Copyright © 2016 Aleksey Storozhev. All rights reserved.
//

@import UIKit;
#import "Node.h"

@class UICollectionViewTreeLayout;
@protocol UICollectionViewDelegateTreeLayout <UICollectionViewDelegate>
- (Node *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewTreeLayout *)layout nodeForIndexPath:(NSIndexPath *)indexPath;
@end

@interface UICollectionViewTreeLayout : UICollectionViewLayout
@end
