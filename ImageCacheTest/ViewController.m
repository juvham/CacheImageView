//
//  ViewController.m
//  ImageCacheTest
//
//  Created by Juvham on 14/12/3.
//  Copyright (c) 2014年 GouMin. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+Cache.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.

    UIImageView *image = [[UIImageView alloc] init];

    image.frame = self.view.bounds ;

    image.tag = 1000;


    [image setImageWithURL:[NSURL URLWithString:@"http://c1.cdn.goumin.com/diary/diary/201412/03/201412031332182111.jpg"] placeholderImage:[UIImage imageNamed:@"canvas"]];

    [_imageView setImageWithURL:[NSURL URLWithString:@"http://c1.cdn.goumin.com/diary/diary/201412/03/201412031332182111.jpg"] placeholderImage:[UIImage imageNamed:@"canvas"]];

//    [image loadUrl];

//    [self.view addSubview:image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loadImage:(id)sender {


    UIImageView *vie = (UIImageView *)[self.view viewWithTag:1000];

    [vie setImageWithURL:[NSURL URLWithString:@"http://c1.cdn.goumin.com/diary/diary/201412/03/201412031332182111.jpg"] placeholderImage:[UIImage imageNamed:@"canvas"]];

//    [_imageView setImageWithURL:[NSURL URLWithString:@"http://c1.cdn.goumin.com/diary/diary/201412/03/201412031332182111.jpg"] placeholderImage:[UIImage imageNamed:@"canvas"]];

//    [self.imageView loadUrl];
}

@end
