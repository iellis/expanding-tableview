//
//  ExpandingTableView.m
//  Present
//
//  Created by Ike Ellis on 9/16/13.
//
//

#import "ExpandingTableView.h"

static NSString *cellID = @"Cell";
static NSString *headerCellID = @"Category";

@interface ExpandingTableView () {
    
    NSIndexPath *_selectedIndexPath;
    NSInteger _selectedCategoryIndex;
    
}


@end

@implementation ExpandingTableView

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    
    return self;
}

- (void)awakeFromNib {
    [self setupControl];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupControl];
    }
    
    return self;
}

- (void)setupControl {
    _selectedIndexPath = nil;
    _selectedCategoryIndex = -1;
    
    self.backgroundColor = [UIColor clearColor];
    
    if (_tableView) {
        [_tableView removeFromSuperview];
        _tableView = nil;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
    
}

- (void)reloadData {
    [_tableView reloadData];
}


- (NSInteger)cellCountForSelectedCategory {
    
    if (_selectedCategoryIndex < 0) {
        return 0;
    }
    
    return ((NSNumber *)_cellCountPerCategory[_selectedCategoryIndex]).integerValue;
}

- (BOOL)isCategoryCellIndexPath:(NSIndexPath *)indexPath {

    BOOL retVal = YES;
    
    if (_selectedIndexPath && indexPath.row > _selectedIndexPath.row && indexPath.row <= _selectedIndexPath.row + [self cellCountForSelectedCategory]) {
        retVal = NO;
    }
    
    return retVal;
}

- (int)categoryIndexForIndexPath:(NSIndexPath *)indexPath {
    
    int index = -1;
    if (indexPath) {
    
        if (!_selectedIndexPath || indexPath.row <= _selectedIndexPath.row) {
            //above the selection
            index = indexPath.row;
        } else if (indexPath.row >= _selectedIndexPath.row + [self cellCountForSelectedCategory]) {
            //below the selection
            index = indexPath.row - [self cellCountForSelectedCategory];
        } else if (_selectedIndexPath) {
            //this is a cell, so return its owning category
            index = _selectedIndexPath.row;
        }
    }
    
    return index;
}

- (int)cellIndexForIndexPath:(NSIndexPath *)indexPath {
    
    int index = -1;
    
    if (_selectedIndexPath && ![self isCategoryCellIndexPath:indexPath]) {
        index = indexPath.row - (_selectedIndexPath.row + 1);
    }
    
    return index;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _categoryCount + [self cellCountForSelectedCategory];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    UITableViewCell *retCell = nil;
    if (![self isCategoryCellIndexPath:indexPath]) {
        //dequeue a cell
        retCell = [_delegate cellForCategoryWithIndex:[self categoryIndexForIndexPath:indexPath] andCellIndex:[self cellIndexForIndexPath:indexPath] forIndexPath:indexPath] ;
        
    } else {
        //dequeue a criteria
        retCell = [_delegate cellForCategoryWithIndex:[self categoryIndexForIndexPath:indexPath] forIndexPath:indexPath];
    }
    
    return retCell;
}

#pragma mark ScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_delegate expandingTableViewDidScroll:self];
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height;
    if ([self isCategoryCellIndexPath:indexPath]) {
        height = _categoryHeight;
    } else {
        height = _cellHeight;
    }    
    
    return height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self isCategoryCellIndexPath:indexPath]) {
        return nil;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    int nextCategoryCellCount = ((NSNumber *)_cellCountPerCategory[[self categoryIndexForIndexPath:indexPath]]).intValue;
    int previousCategoryCellCount = [self cellCountForSelectedCategory];
    
    NSMutableArray *deleteRows = [[NSMutableArray alloc] initWithCapacity:previousCategoryCellCount];

    NSInteger insertBase = indexPath.row;

    NSIndexPath *previousSelection = _selectedIndexPath;
    
    if (_selectedIndexPath) {
        //remove the existing cells if there was already a selection (even if the tapped category was already selected)

        _selectedIndexPath = nil;
        _selectedCategoryIndex = -1;
        
        //set the cell as editable
        for (int i = 0; i < previousCategoryCellCount; ++i) {
            [deleteRows addObject:[NSIndexPath indexPathForRow:previousSelection.row+i+1 inSection:0]];
        }
        
        //if the new selection is after an expanded cell, decrement or increment to account for the sub-cells
        if (indexPath.row > previousSelection.row) {
            insertBase -= previousCategoryCellCount;
            previousSelection = [NSIndexPath indexPathForRow:previousSelection.row - previousCategoryCellCount inSection:0];
        } else if (indexPath.row < previousSelection.row) {
            previousSelection = [NSIndexPath indexPathForRow:previousSelection.row + previousCategoryCellCount inSection:0];
        }
        //if they're the same, do nothing
        
        //turn on editing on old row
        UITableViewCell *previousCell = [_tableView cellForRowAtIndexPath:previousSelection];
        [previousCell setEditing:YES animated:YES];
    }
    

    
    NSMutableArray *newRows = nil;
    
    if (!previousSelection || indexPath.row != previousSelection.row) {
        
        //if this was a new selection, add new rows - otherwise this is skipped so that the category closes
        newRows = [[NSMutableArray alloc] initWithCapacity:nextCategoryCellCount];
        for (int i = 0; i < nextCategoryCellCount; ++i) {
            [newRows addObject:[NSIndexPath indexPathForRow:insertBase+i+1 inSection:0]];
        }

        _selectedIndexPath = [NSIndexPath indexPathForRow:insertBase inSection:0];
        _selectedCategoryIndex = [self categoryIndexForIndexPath:_selectedIndexPath];
        
        //disable editing on selected cell
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath]; //use actual indexpath, not adjusted because criteria rows haven't been removed yet
        [cell setEditing:NO animated:YES];
    }

    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationTop];
    if (newRows) {
        //add new rows if there are any
        [tableView insertRowsAtIndexPaths:newRows withRowAnimation:UITableViewRowAnimationTop];
    }
    [tableView endUpdates];
    
    //scroll the view to make sure any new rows are in the view
    if (newRows) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    //notify the delegate of what happened
    [_delegate expandingTableView:self didChangeSelectedCategoryIndexTo:_selectedCategoryIndex andCloseCategoryIndex:[self categoryIndexForIndexPath:previousSelection]];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {

    NSIndexPath *movePath = proposedDestinationIndexPath;
    
    if ([self isCategoryCellIndexPath:sourceIndexPath]) {
        if (proposedDestinationIndexPath.row == _selectedIndexPath.row) {
            //this is a room, currently over the selected room
            int targetRow = MAX(0, _selectedIndexPath.row - 1);
            movePath = [NSIndexPath indexPathForRow:targetRow inSection:0];
            
        } else if (![self isCategoryCellIndexPath:proposedDestinationIndexPath]) {
            //this is a room, currently over a criteria
            
            if (proposedDestinationIndexPath.row > _selectedIndexPath.row + [self cellCountForSelectedCategory]/2) {
                //the criteria is in the bottom half of the list
                int targetRow = _selectedIndexPath.row + [self cellCountForSelectedCategory];
                if (sourceIndexPath.row > _selectedIndexPath.row) {
                    //if the source is below the selection, add one because no cell is going to be removed above the selection after the move
                    ++targetRow;
                }
                movePath = [NSIndexPath indexPathForRow:targetRow inSection:0];
            } else {
                //the criteria is in the top half of the list
                
                //take the place of the current selection
                int targetRow = _selectedIndexPath.row;
                if (sourceIndexPath.row < _selectedIndexPath.row) {
                    //but if we're coming from above the selection, decrement becuase we're also vacating a slot
                    targetRow--;
                }
                
                movePath = [NSIndexPath indexPathForRow:targetRow inSection:0];
            }
        }
    } else {
        if ([self isCategoryCellIndexPath:proposedDestinationIndexPath]) {
            //this is a criteria, currently over a room
            if (proposedDestinationIndexPath.row > _selectedIndexPath.row + [self cellCountForSelectedCategory]) {
                //criteria is below the criteria list
                movePath = [NSIndexPath indexPathForRow:_selectedIndexPath.row + [self cellCountForSelectedCategory] inSection:0];
            } else if (proposedDestinationIndexPath.row <= _selectedIndexPath.row) {
                //criteria is above the criteria list
                movePath = [NSIndexPath indexPathForRow:_selectedIndexPath.row + 1 inSection:0];
            }

        }
    }
    
    return movePath;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //the currently selected row cannot be edited
    return (!_selectedIndexPath || (indexPath.row != _selectedIndexPath.row)) ? YES : NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //only allows reordering, not deleting
    return UITableViewCellEditingStyleNone;
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    if ([self isCategoryCellIndexPath:fromIndexPath]) {
        
        //update the selected index if necessary
        if (fromIndexPath.row < _selectedIndexPath.row && toIndexPath.row > _selectedIndexPath.row) {
            
            //moved a row from below the selection to above it, so decrement the selected row
            int targetRow = MAX(0, _selectedIndexPath.row - 1);
            _selectedIndexPath = [NSIndexPath indexPathForRow:targetRow inSection:0];
        } else if (fromIndexPath.row > _selectedIndexPath.row && toIndexPath.row <= _selectedIndexPath.row) {
            
            //moved a row from above the selection to below it, so increment the selected row
            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row + 1 inSection:0];
        }
        
        _selectedCategoryIndex = [self categoryIndexForIndexPath:_selectedIndexPath];
        
        //re-order the model data
//        int fromCategoryIndex = [self categoryIndexForIndexPath:fromIndexPath];
//        int toCategoryIndex = [self categoryIndexForIndexPath:toIndexPath];
        
        NSAssert(0, @"TODO: fire a delegate method to notify it of the re-ordering");
        
    } else {
        
        NSAssert(0, @"TODO: fire a delegate method to notify it of the re-ordering");
        
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    //the currently selected row cannot be moved
    return (!_selectedIndexPath || (indexPath.row != _selectedIndexPath.row)) ? YES : NO;;
}




@end
