//
//  ORViewController.m
//  randomCat_Working_with_network
//
//  Created by MacBook on 28.10.15.
//  Copyright (c) 2015 Osadchuk. All rights reserved.
//

#import "ORViewController.h"

@interface ORViewController ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *loadCat;
@property (weak, nonatomic) IBOutlet UIButton *logs;

@property(nonatomic,strong)NSURLConnection* urlConnection;
@property(nonatomic,strong)NSMutableData* urlData;


@end

@implementation ORViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)onCatClicked:(id)sender {
    
    self.urlData=[NSMutableData new];
    
    NSURL* url=[NSURL URLWithString:@"http:random.cat/meow"];
    NSURLRequest* request =[NSURLRequest requestWithURL:url];
    NSURLConnection* connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    self.urlConnection=connection;
    self.loadCat.enabled=NO;
    
}

- (IBAction)onLogClicked:(id)sender {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.parse.com/1/classes/Logs"]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"wGuKBRFghDRy3K2JuL9IkCwBssmQ2K0qR2noI5Qx" forHTTPHeaderField:@"X-Parse-Application-Id"];
    
    [request setValue:@"qlAavQKuwnUeCl2L1FcCPUfMMkHJPL75cJjDLsQb" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Roman",@"userID",
                         self.label.text,@"catURL",
                         nil];
    NSError *error;
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil){
             NSError *parseError = nil;
             NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
             
             NSLog(@"dictionary %@",dictionary);
         }
         else if ([data length] == 0 && error == nil){
             NSLog(@"no data returned");
         }
         else if (error != nil)
         {
             NSLog(@"there was a download error");
             
         }
     }];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.urlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if(self.urlData){
        
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.urlData options:NSJSONReadingMutableContainers error:nil];
        
        self.label.text=dict[@"file"];
        
        if (self.label.text) {
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [indicator startAnimating];
            [indicator setCenter:self.imageView.center];
            [self.imageView addSubview:indicator];
            
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.label.text]];
                UIImage *img = [[UIImage alloc] initWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [indicator removeFromSuperview];
                    self.imageView.image = img;
                    self.loadCat.enabled=YES;
                });
            });
            
        }
        
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView* alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Image can't be loaded" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    self.loadCat.enabled=YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        int statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode != 200) {
            self.loadCat.enabled=YES;
            NSLog(@"Status code was %ld, but should be 200.", (long)statusCode);
            NSLog(@"response = %@", response);
        }
    }
}





@end
