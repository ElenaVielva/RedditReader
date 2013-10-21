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
    cachedThumbnails = [[NSMutableDictionary alloc] init];
    [cachedThumbnails setObject:[UIImage imageNamed:@"default-reddit.png"] forKey:@"blank"];
    self.title = [EVGRedditsResultInfo sharedInfo].navTitle;
    
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
    return [[EVGRedditsResultInfo sharedInfo].reddits count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RedditCell"];
    
    EVGReddit *reddit = [[EVGRedditsResultInfo sharedInfo].reddits objectAtIndex:indexPath.row];
	
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
	titleLabel.text = reddit.title;
    
    
	UILabel *authorLabel = (UILabel *)[cell viewWithTag:102];
	authorLabel.text = reddit.author;
    
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:103];
	dateLabel.text = reddit.date;
	
    UIImageView *thumbImage = (UIImageView *) [cell viewWithTag:100];
    if (reddit.thumb!=nil) {
        
        UIImage *cachedImage = [cachedThumbnails objectForKey:reddit.thumb];
        if (cachedImage==nil) {
//            NSLog(@"From url");
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:reddit.thumb]];
            if (img==nil) {
                img = [cachedThumbnails objectForKey:@"blank"];
            }
            thumbImage.image = img;
            
            [cachedThumbnails setObject:img forKey:reddit.thumb];
            
        } else {
//            NSLog(@"From cache");
            thumbImage.image = cachedImage;
        }
        
        thumbImage.frame = CGRectMake(
                                     thumbImage.frame.origin.x,
                                     thumbImage.frame.origin.y, 70, 70);
        
        thumbImage.contentMode = UIViewContentModeBottomLeft; // This determines position of image
        thumbImage.clipsToBounds = YES;
    } else {
//        NSLog(@"No image %@", reddit.author);
        thumbImage.image = [cachedThumbnails objectForKey:@"blank"];
    }
    
    return cell;
}

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_ {
    CGFloat actualPosition = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height;

    if ((contentHeight-actualPosition)<350) {
//        NSLog(@"End of table");
        if (![EVGRedditsResultInfo sharedInfo].loading) {
            [EVGRedditsResultInfo loadMore];
            [self.tableView reloadData];
        }
    }
    if (actualPosition < -70) {
//        NSLog(@"Init of table (actual %f)",actualPosition);
    }
}

@end
