//
//  ViewController.m
//  BlocSpot
//
//  Created by Andrew Carvajal on 7/27/15.
//  Copyright (c) 2015 Andrew Carvajal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIBarButtonItem *searchButton;
@property (nonatomic, strong) UIBarButtonItem *categoriesButton;
@property (weak, nonatomic) IBOutlet MKMapView *map;

@end

@implementation ViewController

#define padding 5;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _map.delegate = self;

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(21.422460, 39.826203);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [_map setRegion:region animated:YES];

    _searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(didPressSearch:)];
    _categoriesButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(didPressCategories:)];

    self.navigationItem.rightBarButtonItems = @[_searchButton, _categoriesButton];
}

- (void)viewWillLayoutSubviews {
    _map.frame = self.view.bounds;
}

#pragma mark - Bar Buttons

- (void)didPressSearch:(UIBarButtonItem *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        _categoriesButton = nil;
    }];
}

- (void)didPressCategories:(UIBarButtonItem *)sender {
    
}

#pragma mark - Miscellaneous

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
