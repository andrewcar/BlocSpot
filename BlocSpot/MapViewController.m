//
//  MapViewController.m
//  BlocSpot
//
//  Created by Andrew Carvajal on 7/27/15.
//  Copyright (c) 2015 Andrew Carvajal. All rights reserved.
//

#import "MapViewController.h"
#import "SearchTableViewController.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIBarButtonItem *searchButton;
@property (nonatomic, strong) UIBarButtonItem *categoriesButton;

@end

@implementation MapViewController

#define padding 5;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:20];
        titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"BlocSpot";
        self.navigationItem.titleView = titleLabel;
        [titleLabel sizeToFit];

        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:12/255.0 green:204/255.0 blue:67/255.0 alpha:1]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _map.delegate = self;
    _searchController.delegate = self;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.773464, -73.970061);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [_map setRegion:region animated:YES];

    _searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(didPressSearch:)];
    _categoriesButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(didPressCategories:)];

    self.navigationItem.rightBarButtonItems = @[_searchButton, _categoriesButton];
}

#pragma mark - Bar Buttons

// user presses search bar button
- (void)didPressSearch:(UIBarButtonItem *)sender {
    SearchTableViewController *searchTVC = [[SearchTableViewController alloc] init];
    searchTVC.definesPresentationContext = YES;

    _searchController = [[UISearchController alloc] initWithSearchResultsController:searchTVC];

    _searchController.searchResultsUpdater = searchTVC;
    _searchController.hidesNavigationBarDuringPresentation = YES;
    _searchController.dimsBackgroundDuringPresentation = NO;
    [_searchController.searchBar setBarTintColor:[UIColor colorWithRed:12/255.0 green:204/255.0 blue:67/255.0 alpha:1]];
    [_searchController.searchBar setTintColor:[UIColor whiteColor]];
    [_searchController.searchBar sizeToFit];

    [self presentViewController:_searchController animated:YES completion:nil];
}

- (void)didPressCategories:(UIBarButtonItem *)sender {

}

#pragma mark - MKMapViewDelegate

//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.longitudeDelta = 0.005;
//    span.latitudeDelta = 0.005;
//    CLLocationCoordinate2D location;
//    location.longitude = userLocation.coordinate.longitude;
//    location.latitude = userLocation.coordinate.latitude;
//    region.span = span;
//    region.center = location;
//    [_map setRegion:region animated:YES];
//}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"search bar text did change");
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidBeginEditing");
    [searchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search bar search button clicked");
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        // Mark location and center
        CLPlacemark *placemark = [placemarks firstObject];

        MKCoordinateRegion region;
        CLLocationCoordinate2D newLocation = [placemark.location coordinate];
        region.center = [(CLCircularRegion *)placemark.region center];

        // Drop pin
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:newLocation];
        [annotation setTitle:searchBar.text]; // also set the subtitle
        [_map addAnnotation:annotation];

        // Scroll to search result
        MKMapRect mapRect = [_map visibleMapRect];
        MKMapPoint point = MKMapPointForCoordinate([annotation coordinate]);
        mapRect.origin.x = point.x - mapRect.size.width * 0.5;
        mapRect.origin.y = point.y - mapRect.size.height * 0.25;
        [_map setVisibleMapRect:mapRect animated:YES];
    }];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    NSLog(@"dismissed search controller");
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
//    NSString *searchString = _searchBar.text;
//    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
//    searchRequest.naturalLanguageQuery = searchString;
//    searchRequest.region = _map.region;
//    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
//    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
//        NSMutableArray *placemarks = [NSMutableArray new];
//        for (MKMapItem *item in response.mapItems) {
//            [placemarks addObject:item.placemark];
//        }
//        [_map removeAnnotations:[_map annotations]];
//        [_map showAnnotations:placemarks animated:YES];
//    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
