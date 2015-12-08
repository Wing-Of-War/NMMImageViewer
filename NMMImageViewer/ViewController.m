//
//  ViewController.m
//  NMMImageViewer
//
//  Created by JUE DUKE on 15/12/7.
//  Copyright © 2015年 JUE DUKE. All rights reserved.
//

#import "ViewController.h"
#import "ImageViewerViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *testList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testList = @[@"Long image load test",
                      @"Small image load test",
                      @"Normal image load test"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - TableView 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testList.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.testList[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [ImageViewerViewController showInViewController:self testType:TestType_Tall];
    } else if (indexPath.row == 1){
        [ImageViewerViewController showInViewController:self testType:TestType_Small];
    } else {
        [ImageViewerViewController showInViewController:self testType:TestType_Normal];
    }
}
@end
