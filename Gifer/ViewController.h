//
//  ViewController.h
//  Gifer
//
//  Created by sun zhuoshi on 1/5/15.
//  Copyright (c) 2015 sunzhuoshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    NSURLConnectionDataDelegate>

@property (nonatomic, strong) IBOutlet UIButton *selectButton;
@property (nonatomic, strong) IBOutlet UIButton *uploadButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) IBOutlet UITextView *textView;

@property (nonatomic, strong) IBOutlet UIButton *openButton;
@property (nonatomic, strong) IBOutlet UIButton *cpButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;

@property (nonatomic, copy) NSString* url;

- (IBAction)doSelectButtonTouchUpInside:(id)sender;
- (IBAction)doUploadButtonTouchUpInside:(id)sender;

- (IBAction)doOpenButtonTouchUpInside:(id)sender;
- (IBAction)doCpButtonTouchUpInside:(id)sender;
- (IBAction)doShareButtonTouchUpInside:(id)sender;

@end
