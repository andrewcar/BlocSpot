//
//  MapViewController.m
//  BlocSpot
//
//  Created by Andrew Carvajal on 7/27/15.
//  Copyright (c) 2015 Andrew Carvajal. All rights reserved.
//

#import "MapViewController.h"
#import "SearchTableViewController.h"
#import "DataSource.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPlacemark *currentLocationPlacemark;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIBarButtonItem *searchBarButton;
@property (nonatomic, strong) UIBarButtonItem *categoriesButton;
@property (nonatomic, strong) UIButton *userLocationButton;

@end

@implementation MapViewController

#define padding 5;

#pragma mark - Initialization

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

    [[NSNotificationCenter defaultCenter] addObserverForName:@"Placemark Tapped" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self showLocationOnMap];
    }];

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }

    _searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(didPressSearchBarButton:)];
    _categoriesButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(didPressCategories:)];

    _userLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _userLocationButton.backgroundColor = [UIColor colorWithRed:12/255.0 green:204/255.0 blue:67/255.0 alpha:1];
    [_userLocationButton addTarget:self action:@selector(didPressLocationButton:) forControlEvents:UIControlEventTouchUpInside];
    [_userLocationButton setTitle:@"Λ" forState:UIControlStateNormal];
    _userLocationButton.titleLabel.font = [UIFont systemFontOfSize:19];
    _userLocationButton.titleLabel.textColor = [UIColor whiteColor];
    _userLocationButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.navigationItem.rightBarButtonItems = @[_searchBarButton, _categoriesButton];
    [self.view addSubview:_userLocationButton];
}

- (void)viewWillLayoutSubviews {
    _userLocationButton.frame = CGRectMake(CGRectGetMinX(self.view.frame) + 20, CGRectGetMaxY(self.view.frame) - 60, 40, 40);
    _userLocationButton.layer.cornerRadius = _userLocationButton.frame.size.height / 2;
    _userLocationButton.layer.masksToBounds = YES;
    _userLocationButton.layer.borderWidth = 0;
}

#pragma mark - Buttons

- (void)didPressSearchBarButton:(UIBarButtonItem *)sender {
    SearchTableViewController *searchTVC = [[SearchTableViewController alloc] init];
    searchTVC.definesPresentationContext = NO;

    _searchController = [[UISearchController alloc] initWithSearchResultsController:searchTVC];
    _searchController.searchBar.delegate = self;
    _searchController.searchResultsUpdater = self;
    _searchController.hidesNavigationBarDuringPresentation = YES;
    _searchController.dimsBackgroundDuringPresentation = NO;
    [_searchController.searchBar setBarTintColor:[UIColor colorWithRed:12/255.0 green:204/255.0 blue:67/255.0 alpha:1]];
    [_searchController.searchBar setTintColor:[UIColor whiteColor]];
    [_searchController.searchBar sizeToFit];

    [self presentViewController:_searchController animated:YES completion:nil];
}

- (void)didPressLocationButton:(UIButton *)sender {
    MKMapRect mapRect = [_map visibleMapRect];
    MKMapPoint point = MKMapPointForCoordinate(_locationManager.location.coordinate);
    mapRect.origin.x = point.x - mapRect.size.width * 0.5;
    mapRect.origin.y = point.y - mapRect.size.height * 0.5;
    [_map setVisibleMapRect:mapRect animated:YES];
    _userLocationButton.backgroundColor = [UIColor colorWithRed:10/255.0 green:162/255.0 blue:53/255.0 alpha:1];
    [UIView animateWithDuration:0.426 animations:^{
        _userLocationButton.backgroundColor = [UIColor colorWithRed:12/255.0 green:204/255.0 blue:67/255.0 alpha:1];
    }];
}

- (void)didPressCategories:(UIBarButtonItem *)sender {

}

- (void)didTapDetailOnPin {

}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchString = searchBar.text;
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = searchString;
    searchRequest.region = _map.region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSMutableArray *placemarks = [NSMutableArray array];
        for (MKMapItem *item in response.mapItems) {
            [placemarks addObject:item.placemark];
        }
        [DataSource sharedInstance].placemarks = placemarks;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Placemarks Updated" object:nil];
        [_map removeAnnotations:[_map annotations]];
        [_map showAnnotations:placemarks animated:YES];
    }];
    [_searchController dismissViewControllerAnimated:NO completion:nil];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    // create search request for the search bar's text
    NSString *searchString = _searchController.searchBar.text;
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = searchString;

    // confine search to current region
    searchRequest.region = _map.region;

    // initialize search request
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        // create array for placemarks
        NSMutableArray *placemarks = [NSMutableArray new];

        // for loop adding placemarks to array
        for (MKMapItem *item in response.mapItems) {
            [placemarks addObject:item.placemark];
        }

        // set the DataSource's placemarks array to the array we just created
        [DataSource sharedInstance].placemarks = placemarks;

        // post notification 1
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Placemarks Updated" object:nil];
    }];
}

#pragma mark - MKMapViewDelegate

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
//    pin.pinColor = MKPinAnnotationColorPurple;
//
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    [button addTarget:self action:@selector(didTapDetailOnPin) forControlEvents:UIControlEventTouchUpInside];
//
//    pin.rightCalloutAccessoryView = button;
//    pin.draggable = NO;
//    pin.animatesDrop = YES;
//    pin.canShowCallout = YES;
//    pin.highlighted = NO;
//
//    return pin;
//}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(manager.location.coordinate.latitude, manager.location.coordinate.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.001, 0.001);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [_map setRegion:region animated:YES];
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error.localizedDescription);
}

#pragma mark - Miscellaneous

- (void)showLocationOnMap {
    [_map removeAnnotations:[_map annotations]];
    [DataSource sharedInstance].placemarks = [@[[DataSource sharedInstance].tappedPlacemarkOnCell] mutableCopy];
    [_map showAnnotations:[DataSource sharedInstance].placemarks animated:YES];
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
