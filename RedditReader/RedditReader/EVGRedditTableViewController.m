//
//  EVGRedditTableViewController.m
//  RedditReader
//
//  Created by Elena Vielva on 20/10/13.
//  Copyright (c) 2013 Elena Vielva. All rights reserved.
//

#import "EVGRedditTableViewController.h"
#import "EVGRedditsResultInfo.h"
#import "EVGReddit.h"

#import "EVGRedditContentViewController.h"

@interface EVGRedditTableViewController ()

@end

@implementation EVGRedditTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    cachedThumbnails = [[NSMutableDictionary alloc] init];
    [cachedThumbnails setObject:[UIImage imageNamed:@"default-reddit.png"] forKey:@"blank"];
    self.title = [EVGRedditsResultInfo sharedInfo].navTitle;
    isLoading = NO;
    loadingImage = [UIImage imageNamed:@"loading.png"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    int numberOfReddits = [[EVGRedditsResultInfo sharedInfo].reddits count];
    if (isLoading || loadingTop) {
        return numberOfReddits+1; // the last one is the loading animation
    }
    return numberOfReddits;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RedditCell"];
    
    
    UIImageView *loadingIcon = (UIImageView *) [cell viewWithTag:104];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *authorLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:103];
    UIImageView *thumbImage = (UIImageView *) [cell viewWithTag:100];
    
    if ( (isLoading && (indexPath.row==[[EVGRedditsResultInfo sharedInfo].reddits count]) ) ||
        (loadingTop && indexPath.row == 0) ) {
        loadingIcon.image = loadingImage;
        
        [self startSpin:loadingIcon];
        
        titleLabel.text = nil;
        authorLabel.text = nil;
        dateLabel.text = nil;
        thumbImage.image = nil;
        return cell;
    }
    loadingIcon.image = nil;
    
    
    EVGReddit *reddit;
    if (loadingTop) {
        NSLog(@"Reading from -1");
        reddit = [[EVGRedditsResultInfo sharedInfo].reddits objectAtIndex:indexPath.row-1];
    }else {
        reddit = [[EVGRedditsResultInfo sharedInfo].reddits objectAtIndex:indexPath.row];
    }
	
    
	titleLabel.text = reddit.title;
	authorLabel.text = reddit.author;
	dateLabel.text = reddit.date;
    if (reddit.thumb!=nil) {
        // The reddit has a thumbnail
        
        UIImage *cachedImage = [cachedThumbnails objectForKey:reddit.thumb];
        if (cachedImage==nil) {
            // There is no cached image for the url of the thumbnail
            
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:reddit.thumb]];
            if (img==nil) {
                // The url of the thumbnail doesn't represent an image => use the default thumbnail
                img = [cachedThumbnails objectForKey:@"blank"];
            }
            thumbImage.image = img;
            
            // To avoid loading each time an image (and thus, slow navigation through the table), cache it with its url
            [cachedThumbnails setObject:img forKey:reddit.thumb];
            
        } else {
            // No need to create a new image, already cached
            thumbImage.image = cachedImage;
        }
        
        thumbImage.frame = CGRectMake(thumbImage.frame.origin.x, thumbImage.frame.origin.y, 70, 70);
        thumbImage.contentMode = UIViewContentModeCenter;//UIViewContentModeBottomLeft; // This determines position of image
        thumbImage.clipsToBounds = YES;
    } else {
        // The reddit has no thumbnail information
        thumbImage.image = [cachedThumbnails objectForKey:@"blank"];
    }
    
    return cell;
}

- (void) spinImage: (UIImageView*) imageToMove WithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         imageToMove.transform = CGAffineTransformRotate(imageToMove.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (isLoading) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinImage:imageToMove WithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinImage:imageToMove WithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin: (UIImageView*)imageView {
    [self spinImage:imageView WithOptions: UIViewAnimationOptionCurveEaseIn];
}

/*- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    isLoading = NO;
}*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"selectRedditSegue"]) {
        EVGRedditContentViewController *detailViewController = [segue destinationViewController];
        
        detailViewController.reddit = [[EVGRedditsResultInfo sharedInfo].reddits objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView_ {
    CGFloat actualPosition = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height;
    
    if (actualPosition < -70) {
        if (!loadingTop) {
            NSLog(@"Init of table (actual %f)",actualPosition);
            loadingTop = YES;
            [self.tableView reloadData];
            
            [self performSelector:@selector(loadDataTop) withObject:Nil afterDelay:0.1];
        }
        
    }
    
    UITableView *table = (UITableView*)[scrollView_ viewWithTag:500];
    actualPosition +=[table bounds].size.height;
    
    if (((actualPosition-contentHeight)>70)&&(contentHeight>0)) {
        if (!isLoading) {
            NSLog(@"End of table %f %f (first)",contentHeight, actualPosition);
            // New elem of table
            isLoading = YES;
            [self.tableView reloadData];
            
            [self performSelector:@selector(loadMoreData) withObject:Nil afterDelay:0.1];
        }
    }
    
}

- (void) loadMoreData {
    [EVGRedditsResultInfo loadMore];
    isLoading = NO;
    [self.tableView reloadData];
}

-(void) loadDataTop {
    if (![EVGRedditsResultInfo loadOnTop]) {
        NSLog(@"Algo");
        
    }
    loadingTop = NO;
    [self.tableView reloadData];
}

/*- (void) animateLoading {
 
    UIView *view;
    CGFloat duration = 1.0;
    CGFloat rotations = 1.0;
    float repeat = 3.0;
    
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}*/

@end
