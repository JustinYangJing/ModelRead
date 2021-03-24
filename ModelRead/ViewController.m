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
    
    Sphere *v = [[Sphere alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    [self.view addSubview:v];
    v.center = self.view.center;
    [v setFBOAndRBO];
//    [v showSphere];
    
    [v showSphereModel];
}


@end
