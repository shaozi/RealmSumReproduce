//
//  TableVC.m
//  dbrealmtest
//
//  Created by Jingshao Chen on 12/8/15.
//  Copyright © 2015 Jingshao Chen. All rights reserved.
//

#import "TableVC.h"
#import "Model.h"
#import "Dogs.h"

@interface TableVC ()
@property (nonatomic, strong) RLMNotificationToken *token;
@property (nonatomic, strong) RLMRealm *database;
@property (nonatomic, strong) RLMResults *persons;
@property (nonatomic, strong) dispatch_queue_t bgq;
@end

@implementation TableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setup];
}

- (RLMRealm *)getEncryptedRealm
{
    return [SRDB sharedDB];
}

- (void)setup
{
    self.bgq = dispatch_queue_create("com.salesram.bgqueu", NULL);
    
    
    self.database = [self getEncryptedRealm];
    
    __typeof__(self) __weak weakSelf = self;
    self.token = [self.database addNotificationBlock:^(NSString * _Nonnull notification, RLMRealm * _Nonnull realm) {
        [weakSelf.tableView reloadData];
        [weakSelf calculateTotal];
    }];
    
    assert([NSThread isMainThread]);
    self.persons = [[Person objectsInRealm:self.database withPredicate:nil]
                    sortedResultsUsingDescriptors:@[ [RLMSortDescriptor sortDescriptorWithProperty:@"id" ascending:YES] ] ];

    UIBarButtonItem *buttonCal = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLotsOfRows:)];
    self.navigationItem.rightBarButtonItem = buttonCal;
    UIBarButtonItem *buttonClear = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(clearDB:)];
    self.navigationItem.leftBarButtonItem = buttonClear;
    
    [self calculateTotal];
}


- (IBAction)clearDB:(UIBarButtonItem *)sender
{
    dispatch_async(self.bgq, ^{
        RLMRealm *db = [self getEncryptedRealm];
        [db beginWriteTransaction];
        [db deleteAllObjects];
        [db commitWriteTransaction];
    });
    [self addLotsOfRows:nil];
}


- (IBAction)addLotsOfRows:(UIBarButtonItem *)sender
{
    //for (int i = 0; i < 10; i++) {
        [self createData:0];
    //}
}

- (void)calculateTotal
{
    assert([NSThread isMainThread]);
    NSNumber *total = [self.persons sumOfProperty:@"walkDistance"];
    double miles = 0;
    for (Person *person in self.persons) {
        miles += [person.walkDistance doubleValue];
    }
    NSString *title = [NSString stringWithFormat:@"sum:%@ loop:%0.0f",total, miles];
    NSLog(@"%@", title);
    self.title = title;
}

- (void)createData:(int)seq
{
    dispatch_async(self.bgq, ^{
        NSLog(@"start %i", seq);
        @autoreleasepool {
            RLMRealm *db = [self getEncryptedRealm];
            //[db refresh];
            [db beginWriteTransaction];
            for (int i = 0; i < 2; i++) {
                
                NSString *pid = [NSString stringWithFormat:@"%i", i];
                Person *person = [Person createOrUpdateInRealm:db withValue:@{@"id": [NSString stringWithFormat:@"%@", pid]}];
                person.name = [NSString stringWithFormat:@"Person Name # %@", pid];
                person.walkDistance = @1;
                
                for (int j = 0; j < arc4random()%10; j++) {
                    
                    Dog *dog = [Dog createOrUpdateInRealm:db withValue:@{@"id": [NSString stringWithFormat:@"%@-%i", pid,j]}];
                    dog.owner = person;
                    if ([person.dogs indexOfObject:dog] == NSNotFound) {
                        [person.dogs addObject:dog];
                    }
                    // the RLMArray is not a set. So one object can be added multiple times.
                    //[person.dogs addObject:dog];
                    dog.name = [NSString stringWithFormat:@"Dog Name # %@-%i", pid,j];
                }
                
                
            }
            [db commitWriteTransaction];
            NSLog(@"end %i", seq);
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.title = [NSString stringWithFormat:@"%ld Persons", self.persons.count];
    return self.persons.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    
    // Configure the cell...
    Person *person = self.persons[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld %@", indexPath.row, person.name];
    RLMResults *dogs = [Dog objectsInRealm:self.database withPredicate:[NSPredicate predicateWithFormat:@"owner = %@", person]];
    //NSArray *dogs = person.dogs;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld dog%@", dogs.count, dogs.count > 1? @"s":@""];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Person *owner = self.persons[indexPath.row];
    Dogs *dvc = segue.destinationViewController;
    dvc.owner = owner;
}


@end
