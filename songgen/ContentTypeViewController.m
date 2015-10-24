//
//  ContentTypeViewController.m
//  songgen
//
//  Created by Nathan Fuller on 10/24/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import "ContentTypeViewController.h"

@interface ContentTypeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *chooseByImgBtn;
@property (weak, nonatomic) IBOutlet UIButton *chooseByKeywordBtn;
@end

@implementation ContentTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationItem] setHidesBackButton:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
