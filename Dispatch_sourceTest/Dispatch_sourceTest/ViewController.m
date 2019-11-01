//
//  ViewController.m
//  Dispatch_sourceTest
//
//  Created by wang on 2019/11/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, assign) NSUInteger totalComplete;
@property (nonatomic) BOOL isRunning;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.totalComplete = 0;
    
    self.queue = dispatch_queue_create("com.vcoding", 0);
    
    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    // 封装我们需要回调的触发函数 -- 响应
    dispatch_source_set_event_handler(self.source, ^{
        
        NSUInteger value = dispatch_source_get_data(self.source); // 取回来值 1 响应式
        self.totalComplete += value;
        NSLog(@"进度：%.2f", self.totalComplete/100.0);
        self.progressView.progress = self.totalComplete/100.0;
    });
    dispatch_resume(self.source);
    self.isRunning     = YES;
}

- (IBAction)didClickedStartOrPauseAction:(UIButton *)sender {
    if (self.isRunning) {// 正在跑就暂停
        dispatch_suspend(self.source);
        dispatch_suspend(self.queue);// mainqueue 挂起
        self.isRunning = NO;
        [sender setTitle:@"暂停中..." forState:UIControlStateNormal];
    }else{
        dispatch_resume(self.source);
        dispatch_resume(self.queue);
        self.isRunning = YES;
        [sender setTitle:@"加载中..." forState:UIControlStateNormal];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"初始化开始，模拟下载业务。。。");
    
    for (NSUInteger index = 0; index < 100; index++) {
        dispatch_async(self.queue, ^{
            if (!self.isRunning) {
                NSLog(@"暂停下载");
                return ;
            }
            sleep(1);

            dispatch_source_merge_data(self.source, 1); // source 值响应
        });
    }
}

@end
