//
//  ScanResultViewController.m

#import "ScanResultViewController.h"

@interface ScanResultViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *scanImg;
@property (weak, nonatomic) IBOutlet UILabel *labelScanText;
@property (weak, nonatomic) IBOutlet UILabel *labelScanCodeType;
@property(strong,nonatomic)UIWebView *webView;
@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描结果";
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    NSLog(@"11%@",_strScan);
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.webView.delegate = self;
    [self.view addSubview: self.webView];
    NSString *urlString = _strScan;
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.webView loadRequest:request];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL * url = [request URL];
    NSLog(@"%@",url);
    
    if ([[url scheme] isEqualToString:@"firstclick"]) {
        NSArray *params =[url.query componentsSeparatedByString:@"&"];
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (NSString *paramStr in params) {
            NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
            if (dicArray.count > 1) {
                NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [tempDic setObject:decodeValue forKey:dicArray[0]];
            }
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"方式一" message:@"这是OC原生的弹出窗" delegate:self cancelButtonTitle:@"收到" otherButtonTitles:nil];
        [alertView show];
        NSLog(@"tempDic:%@",tempDic);
        return NO;
    }
    
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if (!_imgScan) {
//        
//        _scanImg.backgroundColor = [UIColor grayColor];
//    }
//    _scanImg.image = _imgScan;
//    _labelScanText.text = _strScan;
//    _labelScanCodeType.text = [NSString stringWithFormat:@"码的类型:%@",_strCodeType];
}


@end
