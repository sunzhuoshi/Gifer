//
//  ViewController.m
//  Gifer
//
//  Created by sun zhuoshi on 1/5/15.
//  Copyright (c) 2015 sunzhuoshi. All rights reserved.
//

#import "ViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NSString *UPLOAD_URL = @"http://192.168.199.194/~sunzhuoshi/upload/upload.php";


void GFAlert2(NSString *title, NSString *message, NSString *buttonTitle, id<UIAlertViewDelegate> delegate)
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:delegate
                                               cancelButtonTitle:nil
                                               otherButtonTitles:buttonTitle, nil];
    [alertView show];
}

void GFAlert(NSString *title, NSString *message, NSString *buttonTitle)
{
    GFAlert2(title, message, buttonTitle, nil);
}

void GFAlertError(NSError* error)
{
    NSLog(@"Error: %@", [error description]);
    GFAlert(@"出错了！", [error localizedDescription], @"知道了");
}

@interface ViewController ()

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) NSData* imageData;
@property (nonatomic, copy) NSString* imageName;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation ViewController

@synthesize connection = _connection;
@synthesize url = _url;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.url = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSelectButtonTouchUpInside:(id)sender
{
    [self showImagePicker];
}

- (void)upload: (NSData *)imageData
{
    if (imageData && !self.connection) {
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSMutableURLRequest *requestImg = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPLOAD_URL]
                                                                  cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval: 60.0f];
        [requestImg setHTTPMethod:@"POST"];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [requestImg addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 512];
        [postData setData:imageData];
        
        NSMutableData *body = [NSMutableData data];

        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", self.imageName]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n", [[self.imageName pathExtension] lowercaseString]]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:postData];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [requestImg setHTTPBody:body];
        
        self.connection = [NSURLConnection connectionWithRequest:requestImg delegate:self];
        
        if (self.connection) {
        } else {
            NSLog(@"Connection failed");
            GFAlert(@"出错了！", @"连接服务器失败", @"知道了");
        }
    }
}

- (IBAction)doUploadButtonTouchUpInside:(id)sender
{
    if (self.imageData) {
        [self upload:self.imageData];
    }
    else {
        GFAlert(@"点击上图选择要上传的图片", nil, @"好的");
    }
}

- (IBAction)doOpenButtonTouchUpInside:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
}

- (IBAction)doCpButtonTouchUpInside:(id)sender
{
    [UIPasteboard generalPasteboard].string = [self.url copy];
    GFAlert(@"复制成功!", nil, @"好的");
}

- (IBAction)doShareButtonTouchUpInside:(id)sender
{
    GFAlert(@"开发中...", nil, @"好的");
}

- (void)showImagePicker
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSUInteger size = (NSInteger)rep.size;
        Byte *buffer = (Byte*)malloc(size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0 length:size error:nil];
        self.imageData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        self.imageName = rep.filename;
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failureBlock:^(NSError *err) {
        [self dismissViewControllerAnimated:YES completion:NULL];
        GFAlertError(err);
    }];
    self.url = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (connection == self.connection) {
        self.connection = nil;
        GFAlertError(error);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == self.connection) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        if (200 != res.statusCode) {
            GFAlert(@"出错了！", [NSString stringWithFormat: @"状态码: %d", res.statusCode], @"知道了");
            self.connection = nil;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == self.connection) {
        NSError *error;
        id res = [NSJSONSerialization JSONObjectWithData: data options:0 error:&error];
        if (error) {
            GFAlertError(error);
                }
        else {
            NSNumber *code = [res objectForKey:@"code"];
            NSString *msg = [res objectForKey:@"msg"];
            NSString *url = [res objectForKey:@"url"];
            
            if (code.intValue == 0) {
                NSLog(@"url: %@", url);
                self.url = url;
            }
            else {
                NSLog(@"code: %d, msg: %@", code.intValue, msg);
                GFAlert(@"出错了！", msg, @"知道了");
            }
        }
        self.connection = nil;
    }
}

- (void)setConnection:(NSURLConnection *)connection
{
    _connection = connection;
    if (self.connection) {
        self.url = nil;
        [self.activityIndicatorView startAnimating];
        self.uploadButton.enabled = NO;
    }
    else {
        [self.activityIndicatorView stopAnimating];
        self.uploadButton.enabled = YES;
    }
}

- (void)setUrl: (NSString *)url
{
    _url = [url copy];
    if (self.url) {
        self.textView.text = self.url;
        self.textView.hidden = NO;
        self.shareButton.hidden = NO;
        self.cpButton.hidden = NO;
        self.openButton.hidden = NO;
    }
    else {
        self.textView.text = @"";
        self.textView.hidden = YES;
        self.shareButton.hidden = YES;
        self.cpButton.hidden = YES;
        self.openButton.hidden = YES;
    }
}

@end
