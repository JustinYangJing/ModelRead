//
//  ViewController.m
//  ModelRead
//
//  Created by JustinYang on 2021/3/22.
//

#import "ViewController.h"
#import "Sphere.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Sphere *v = [[Sphere alloc] initWithFrame:CGRectMake(0, 0, 350, 350)];
    v.center = self.view.center;
    [self.view addSubview:v];
    [v setFBOAndRBO];
//    [v showSphere];
    [v showSphereModel];
    self.view.backgroundColor = UIColor.blackColor;
}


@end
