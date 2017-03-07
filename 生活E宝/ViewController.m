//
//  ViewController.m
//  生活E宝
//
//  Created by Admin on 16/12/14.
//  Copyright © 2016年 Admin. All rights reserved.
//
#define WEBURL  @"http://101.200.77.119:8080/service/homepage.html#"
#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "BeforeScanSingleton.h"
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UShareUI.h>
#import "UMengHander.h"
@interface ViewController ()<WKUIDelegate,WKScriptMessageHandler,WKNavigationDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic)   UIProgressView  *progressView;
//返回按钮
@property (nonatomic)UIBarButtonItem* customBackBarItem;
//关闭按钮
@property (nonatomic)UIBarButtonItem* closeButtonItem;
//保存请求链接
@property (nonatomic)NSMutableArray* snapShotsArray;
//保存的网址链接
@property (nonatomic, copy) NSString *URLString;
//仅当第一次的时候加载
@property(nonatomic,assign) BOOL isFristLoad;

@property (nonatomic,strong) UMengHander *hander;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFristLoad = YES;
    [self initWKWebView];
    [self initProgressView];
   _hander = [UMengHander share];
    //开启监听进度条!
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    //添加右边刷新按钮roadLoadClicked
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(sharBtnClicked)];
//    UIBarButtonItem *roadLoad = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(sharBtnClicked)];
    self.navigationItem.rightBarButtonItem = btn;
}
//进度条
- (void)initProgressView
{
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 50)];
    progressView.tintColor = [UIColor blueColor];
    progressView.trackTintColor = [UIColor lightGrayColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
}
- (void)rightClick
{
    [self.webView goBack];
}
- (void)dealloc
{
    NSLog(@"dealloc %s",__FUNCTION__);
    //移除监听进度
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}
//初始化页面
- (void)initWKWebView
{
    self.title = @"baidu";
    //进行配置控制器
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    //实例化对象
    configuration.userContentController = [WKUserContentController new];
    //允许视频播放
//    configuration.allowsAirPlayForMediaPlayback = YES;
    // 允许在线播放
    configuration.allowsInlineMediaPlayback = YES;
    // 允许可以与网页交互，选择视图
    configuration.selectionGranularity = YES;
    // 是否支持记忆读取
    configuration.suppressesIncrementalRendering = YES;
    //调用JS方法,下面代码是给html文件注入js代码：移动端html标签的id和网页版可能不一样。
    [configuration.userContentController addScriptMessageHandler:self name:@"erweima"];
    NSString *STR = @"var script = document.createElement('script');script.type = 'text/javascript';script.text = function yourfunction(){var img = document.querySelector('.erweima img');img.addEventListener('touchstart',function(){window.webkit.messageHandlers.erweima.postMessage(null);})}();document.getElementsByTagName('head')[0].appendChild(script);";
    //WKUserScript* scr =  [[WKUserScript alloc]initWithSource:@"var script = document.createElement('script');script.type = 'text/javascript';script.text = function myFunction() {alert(123)};document.getElementsByTagName('head')[0].appendChild(script);" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserScript *SCR2 = [[WKUserScript alloc]initWithSource:STR injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    //    [configuration.userContentController addUserScript:scr];
    [configuration.userContentController addUserScript:SCR2];
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 40.0;
    configuration.preferences = preferences;
    CGRect frame = CGRectMake(0, 2, kScreenWidth, kScreenHeight);
    self.webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:WEBURL]];
    [self.webView loadRequest:request];
    self.webView.scrollView.bounces = YES;
    self.webView.scrollView.delegate = self;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
//    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
//    btn.backgroundColor = [UIColor redColor];
//    [self.view addSubview:btn];
//    [btn addTarget:self action:@selector(sharBtnClicked) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark ================ 自定义返回/关闭按钮 ================

-(void)updateNavigationItems{
    if (!self.webView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem] animated:NO];
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem]];
    }
}
-(UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
        UIImage* backItemImage = [[UIImage imageNamed:@"backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* backItemHlImage = [[UIImage imageNamed:@"backItemImage-hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

-(NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}
#pragma mark - 按钮点击事件
- (void)roadLoadClicked{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:WEBURL]];
    [self.webView loadRequest:request];
}

-(void)customBackItemClicked{
    if (self.webView.goBack) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)erweima{
    [[BeforeScanSingleton shareScan] ShowSelectedType:AliPayStyle WithViewController:self];
}
#pragma mark - WKScriptMessageHandler
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

//这里是js中的方法传回来的参数
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"js中的方法传回来的参数body:%@",message.name);
    if ([message.name isEqualToString:@"erweima"]) {
        [self erweima];
    }
}
#pragma mark - 进度条
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}
#pragma mark ================ WKNavigationDelegate ================

//这个是网页加载完成，导航的变化
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    // 判断是否需要加载（仅在第一次加载）
    if (self.isFristLoad) {
        self.isFristLoad = NO;
    }else{
        [self updateNavigationItems];
    }
    // 获取加载网页的标题
    self.title = @"生活E宝";
}

  //开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
}

//内容返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{}

//服务器请求跳转的时候调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{}

// 内容加载失败时候调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"页面加载超时");
}

//跳转失败的时候调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{}

//进度条
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{}
#pragma mark --上滑动隐藏导航栏
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    if(velocity.y>0)
//    {
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//    }
//    else
//    {
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//    }
}


#pragma  mark - ========友盟=======
//点击分享按钮
- (void)sharBtnClicked{
    __weak typeof(self) weakSelf = self;
//    显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        NSLog(@"信息是userInfo:%@,platformType:%ld",userInfo,(long)platformType);
        [weakSelf runShareWithType:platformType];
    }];
     
}
- (void)runShareWithType:(UMSocialPlatformType)type
{
    [self shareWebPageToPlatformType:type];
}
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"生活e宝" descr:@"欢迎使用生活e宝" thumImage:nil];
    //设置网页地址
    shareObject.webpageUrl = WEBURL;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        [self alertWithError:error];
    }];
}
- (void)alertWithError:(NSError *)error
{
    NSString *result = nil;
    if (!error) {
        result = [NSString stringWithFormat:@"分享成功"];
    }
    else{
        NSMutableString *str = [NSMutableString string];
        if (error.userInfo) {
            for (NSString *key in error.userInfo) {
                [str appendFormat:@"%@ = %@\n", key, error.userInfo[key]];
            }
        }
        if (error) {
            result = [NSString stringWithFormat:@"分享失败, error code: %d\n%@",(int)error.code, str];
        }
        else{
            result = [NSString stringWithFormat:@"分享失败"];
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒"
                                                    message:result
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"确定", @"确定")
                                          otherButtonTitles:nil];
    [alert show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
