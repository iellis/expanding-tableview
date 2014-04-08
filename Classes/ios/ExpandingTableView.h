//
//  ExpandingTableView.h 
//
//  Created by Ike Ellis on 9/16/13.
//
//

/**
 Manages a tableview with categories and cells within the categories. Categories can be expanded/collapsed and
 cells within each category can be reordered.
 
 **/

#import <UIKit/UIKit.h>

@class ExpandingTableView;

@protocol ExpandingTableViewDelegate

- (UITableViewCell *)cellForCategoryWithIndex:(NSInteger)categoryIndex forIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)cellForCategoryWithIndex:(NSInteger)categoryIndex andCellIndex:(NSInteger)cellIndex forIndexPath:(NSIndexPath *)indexPath;
- (void)expandingTableView:(ExpandingTableView *)expandingTableView didChangeSelectedCategoryIndexTo:(NSInteger)selectedIndex andCloseCategoryIndex:(NSInteger)closedIndex;
- (void)expandingTableViewDidScroll:(ExpandingTableView *)expandingTableView;

@end


@interface ExpandingTableView : UIView <UITableViewDataSource, UITableViewDelegate>



- (void)reloadData;

@property (strong, nonatomic) IBOutlet id<ExpandingTableViewDelegate> delegate;

//access the tableView for customization
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger categoryCount;
@property (strong, nonatomic) NSArray *cellCountPerCategory;

@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) CGFloat categoryHeight;


@end
