//
//  ViewController.m
//  RAC
//
//  Created by apple on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userLbl;
@property (weak, nonatomic) IBOutlet UILabel *pwdLbl;

@property (weak, nonatomic) IBOutlet UITextField *userTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (nonatomic, copy) NSString *userName;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     RACSiganl :在RAC中最核心的类
     RACSiganl:信号类,一般表示将来有数据传递，只要有数据改变，信号内部接收到数据，就会马上发出数据。

     RACSubscriber: 订阅者 用来发送信号

     RACDisposable: 用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它

     RACSubject: 信号提供者 ，自己可以充当信号，又能发送信号
     */
    //1、创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        //2、发送信号
        [subscriber sendNext:@"我是一个信号类"];
        //如果不再发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号被销毁" );
        }];

    }];

    //3、订阅信号，才会激活信号
    [signal subscribeNext:^(id x) {
        NSLog(@"接受的数据是%@", x);
    }];


    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者：%@", x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者：%@", x);
    }];
    [subject sendNext:@"发送信号"];

    //MARK: Event
    //监听按钮的点击事件
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        NSLog(@"点击登录按钮了");
    }];
    //MARK: KVO观察者
    //    [[self.userTF.text rac_valuesForKeyPath:NSKeyValueChangeNewKey observer:nil]subscribeNext:^(id x) {
    //        NSLog(@"用户名发生改变了:%@", x);
    //    }];

    [[self.userTF rac_textSignal]subscribeNext:^(id x) {
        NSLog(@"用户文本框发生了改变:%@", x);
    }];
    self.userTF.delegate = self;
    [[self rac_signalForSelector:@selector(textFieldShouldEndEditing:) fromProtocol:@protocol(UITextFieldDelegate)]subscribeNext:^(RACTuple *tuple) {
        NSLog(@"********%@", ((UITextField *)tuple.first).text);
    }];

    // 通过RAC提供的宏快速实现textSingel的监听
    // 当textField的文字发生改变时，label的文字也发生改变
    //RAC(self.userLbl, text) = self.userTF.rac_textSignal;

}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

@end
