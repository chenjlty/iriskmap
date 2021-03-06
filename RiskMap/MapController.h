//
//  MapController.h
//  RiskMap
//
//  Created by Steven on 13-6-26.
//  Copyright (c) 2013年 laka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYCustomMultiSelectPickerView.h"

@interface MapController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate, CYCustomMultiSelectPickerViewDelegate>{
    CYCustomMultiSelectPickerView *multiPickerView;
}

@property (nonatomic, retain) NSMutableArray *objectArray;
@property (nonatomic, retain) NSMutableArray *toolsArray;
@property (nonatomic, retain) IBOutlet UIView *toolView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView2;
@property (nonatomic, retain) IBOutlet UIView *mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backItem;
@property (nonatomic, retain) NSArray *currLinked;
@property (nonatomic, readwrite) int target;
@property (nonatomic, readwrite) int maxX;
@property (nonatomic, readwrite) int maxY;
@property (nonatomic, readwrite) int minX;
@property (nonatomic, readwrite) int minY;
@property (nonatomic, readwrite) int offsetX;
@property (nonatomic, readwrite) int offsetY;
@property (nonatomic, readwrite) int mSize;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain)  NSMutableArray *layers;
@property (nonatomic, retain)  NSMutableArray *entries;
@property (nonatomic, retain)  NSMutableArray *entriesSelected;
@property (nonatomic, retain)  NSMutableDictionary *selectionStates;

- (void) showObject ;

@end
