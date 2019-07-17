//
//  ViewController.m
//  M80ImageMerger
//
//  Created by amao on 11/27/15.
//  Copyright © 2015 M80. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "M80ImageViewController.h"
#import "UIView+Toast.h"
#import "M80MainInteractor.h"
#import "M80ImageGenerator.h"



@interface ViewController ()<M80MainIteractorDelegate>

@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (strong,nonatomic) M80MainInteractor *iteractor;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _okButton.layer.cornerRadius = 5.0;
    _okButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _okButton.layer.borderWidth = 1;
    _okButton.layer.masksToBounds = YES;

    _iteractor = [[M80MainInteractor alloc] init];
    _iteractor.delegate = self;
    [_iteractor run];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)onMergeBegin:(id)sender {
    [_iteractor chooseImages];
}

#pragma mark - M80MainIteractorDelegate
- (void)photosRequestAuthorizationFailed
{
    [self.view makeToast:@"Please Get the Permission Of Photo Library"];
}

- (void)showResult:(M80MergeResult *)result
{
    NSError *error = result.error;
    if (error)
    {
        NSInteger code = [error code];
        switch (code) {
            case M80MergeErrorNotSameWidth:
                [self showNotSameWidthTip];
                break;
            case M80MergeErrorNotEnoughOverlap:
                [self showNotEnoughOverlapError];
                break;
            default:
                assert(0);
                break;
        }
    }
    else
    {
        [self showImageResult:result];
    }
}

- (void)mergeBegin
{
    [SVProgressHUD show];
}

- (void)mergeEnd
{
    [SVProgressHUD dismiss];
}


#pragma mark - misc
- (void)showNotSameWidthTip
{
    [self.view makeToast:@"Please Use The Same Width Image"];
}

- (void)showNotEnoughOverlapError
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Splicing Failed"
                                                                        message:@"Please select an image with enough overlap to splicing"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Sure"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [controller addAction:action];
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
}

- (void)showImageResult:(M80MergeResult *)result
{
    dispatch_block_t block = ^{
        
        M80ImageViewController *vc = [[M80ImageViewController alloc] initWithImage:result.image];
        vc.completion = result.completion;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav
                           animated:YES
                         completion:nil];
    };
    
    
    if (self.presentedViewController != nil)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:block];
    }
    else
    {
        block();
    }
}


@end
