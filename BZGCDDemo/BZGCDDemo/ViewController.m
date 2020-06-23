//
//  ViewController.m
//  BZGCDDemo
//
//  Created by brandon on 2020/6/18.
//  Copyright © 2020 brandon_zheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tv;

@property(nonatomic,copy)NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BZGCDDemo";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
}

- (void)initUI{
    self.tv = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight, iScreenW, iScreenH-(kNavBarAndStatusBarHeight+kBottomSafeHeight)) style:UITableViewStylePlain];
    self.tv.dataSource = self;
    self.tv.delegate = self;
    [self.tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tv];
}

#pragma mark - UITableViewDelegate&UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self syncNConcurrentQ];
    }else if (indexPath.row == 1){
        [self asyncNConcurrentQ];
    }else if (indexPath.row == 2){
        [self syncNSerialQ];
    }else if (indexPath.row == 3){
        [self asyncNSerialQ];
    }else if (indexPath.row == 4){
        [self syncNMainQ];
    }else if (indexPath.row == 5){
        [self syncNMainQInOtherThread];
    }else if (indexPath.row == 6){
        [self asyncNMainQ];
    }else if (indexPath.row == 7){
        [self communication];
    }else if (indexPath.row == 8){
        [self barrierAsync];
    }else if (indexPath.row == 9){
        [self dispatchAfter];
    }else if (indexPath.row == 10){
        [self once];
    }else if (indexPath.row == 11){
        [self apply];
    }else if (indexPath.row == 12){
        [self groupNotify];
    }else if (indexPath.row == 13){
        [self groupWait];
    }else if (indexPath.row == 14){
        [self groupEnterAndLeave];
    }else if (indexPath.row == 15){
        [self Semaphore];
    }
}

#pragma mark - GCD Method
/*
 *同步执行+并发队列
 *所有任务都是在主线程中执行的，没有开启新的线程，不具备开启新线程的能力
 *所有任务都是在begin，end之间执行的，同步任务需要等待队列任务结束
 *任务是按顺序执行的，因为虽然是并发队列，但是同步执行不具备开启新线程的能力，只有一个线程，而且同步执行需要等待之前任务结束，所以是按顺序一个一个执行
 */

- (void)syncNConcurrentQ{
    NSLog(@"打印当前线程----------%@",[NSThread currentThread]);
    NSLog(@"syncConcurrentQ----------begin");
    dispatch_queue_t queue = dispatch_queue_create("com.bzgcddemo.testqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    NSLog(@"syncConcurrentQ----------end");
}

/*
 *异步执行+并发队列
 *除了主线程，又会开启其他线程，异步和并发都具备开启新线程的能力
 *执行顺序不定，异步无需等待
 */
- (void)asyncNConcurrentQ{
    NSLog(@"打印当前线程----------%@",[NSThread currentThread]);
    NSLog(@"syncConcurrentQ----------begin");
    dispatch_queue_t queue = dispatch_queue_create("com.bzgcddemo.testqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"11---%@",[NSThread currentThread]);
        NSLog(@"12---%@",[NSThread currentThread]);
        NSLog(@"13---%@",[NSThread currentThread]);
        NSLog(@"14---%@",[NSThread currentThread]);
        NSLog(@"15---%@",[NSThread currentThread]); // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    NSLog(@"syncConcurrentQ----------end");
}

/*
 *同步执行+串行队列
 *所有任务都是在主线程执行的，不具备开启新线程的能力
 *所有任务都是在begin-end之间执行，同步会等待
 *任务之间也是按顺序执行，串行会等待
 */
- (void)syncNSerialQ{
    NSLog(@"打印当前线程----------%@",[NSThread currentThread]);
    NSLog(@"syncConcurrentQ----------begin");
    dispatch_queue_t queue = dispatch_queue_create("com.bzgcddemo.testqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    NSLog(@"syncConcurrentQ----------end");
}

/*
 *异步执行+串行队列
 */
- (void)asyncNSerialQ{
    NSLog(@"打印当前线程----------%@",[NSThread currentThread]);
    NSLog(@"syncConcurrentQ----------begin");
    dispatch_queue_t queue = dispatch_queue_create("com.bzgcddemo.testqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    NSLog(@"syncConcurrentQ----------end");
}

/*
 *同步执行+主线程
 *造成死锁，主线程和同步任务互相等待
 *syncNMainQ任务被添加到主线程中，同步执行会等待syncNMainQ执行完毕，而任务1也被添加进入主线程队列中，任务1会等待syncNMainQ执行完毕，syncNMainQ会等待任务1执行完毕
 */
- (void)syncNMainQ{
    NSLog(@"打印当前线程----------%@",[NSThread currentThread]);
    NSLog(@"syncConcurrentQ----------begin");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    NSLog(@"syncConcurrentQ----------end");
}

/*
 *在其他线程中执行（同步+主线程）
 *所有任务都是在主线程中执行的，没有开启新的线程，任务是顺序执行的，同步会等待上一个任务执行完毕
 *为什么不回死锁，因为syncNMainQ相当于被加入到了其他线程执行，而队列内的任务则是在主线程中执行
 */
- (void)syncNMainQInOtherThread{
    [NSThread detachNewThreadSelector:@selector(syncNMainQ) toTarget:self withObject:nil];
}

/*
 *异步执行+主线程
 *任务并不会在begin-end之间进行，因为异步不等待
 *由于是主队列，因此并不会开启新的线程，只会在主线程中依次执行
 */
- (void)asyncNMainQ{
    NSLog(@"打印当前线程----------%@",[NSThread currentThread]);
    NSLog(@"syncConcurrentQ----------begin");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    NSLog(@"syncConcurrentQ----------end");
}

/*
 *线程间通信
 *在其他线程中先执行任务，然后回到主线程中再执行
 */
- (void)communication{
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 异步追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);
        
        // 回到主线程
        dispatch_async(mainQueue, ^{
            // 追加在主线程中执行的任务
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
}

/*
 *GCD栅栏方法
 *一旦开启异步并发队列，我们的线程执行顺序将是未知的，如果想保证一些操作的执行顺序便可以使用栅栏
 *而且栅栏方法执行时是会等待的
 */
- (void)barrierAsync{
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_barrier_async(queue, ^{
        // 追加任务 barrier
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"barrier---%@",[NSThread currentThread]);// 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 4
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"4---%@",[NSThread currentThread]);      // 打印当前线程
    });
}

/*
 *GCD延时执行方法
 *在设定之间之后将任务追加到相应线程中
 *并不是绝对准确的
 */
- (void)dispatchAfter{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0 秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
    });
}

/*
 *GCD只执行一次的代码
 *此方法可以保证代码在程序运行过程中只执行一次
 */
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行 1 次的代码（这里面默认是线程安全的）
        NSLog(@"执行了");
    });
}

/*
 *GCD快速迭代方法
 *按照指定的次数将指定的追加到指定的队列中，并等待任务全部结束
 *如果在串行队列中使用就和for循环一样，按顺序同步执行
 *在并发队列中可以在多个线程中异步遍历多个数字
 *apply会等待任务执行完毕
 */
- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
    });
    NSLog(@"apply---end");
}

/*
 *GCD队列组
 *两个耗时任务分别异步执行
 *执行完毕后通知主线程
 */
- (void)groupNotify {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步任务 1、任务 2 都执行完毕后，回到主线程执行下边任务
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程

        NSLog(@"group---end");
    });
}

/*
 *阻塞当前的线程
 *暂停当前线程，等待指定group中的任务执行完毕后才会继续往下执行
 */
- (void)groupWait{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"group---end");
}

/*
 *线程组加入和离开
 *enter表示将任务加入到线程组
 *leave表示执行完离开线程组
 *只有线程组中任务数为0，才会解除阻塞
 */

- (void)groupEnterAndLeave{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        
        NSLog(@"group_end");
    });
}

/*
 *信号量，当信号量大于等于0的时候可以执行，小于0的时候将阻塞
 *信号量的使用前提是：想清楚你需要处理哪个线程等待（阻塞），又要哪个线程继续执行，然后使用信号量。
 */
- (void)Semaphore{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block int number = 0;
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        number = 100;
        
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"semaphore---end,number = %d",number);
}

#pragma mark - getter&setter

- (NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = @[@"同步执行 + 并发队列",@"异步执行+并发队列",@"同步执行+串行队列",@"异步执行+串行队列",@"同步执行+主线程",@"其他线程中执行（同步+主线程）",@"异步执行+主线程",@"线程间通信",@"GCD栅栏方法",@"GCD延时执行方法",@"只执行一次",@"GCD快速迭代方法",@"GCD队列组",@"阻塞当前线程",@"队列组enter leave",@"GCD 信号量线程同步"];
    }
    return _dataArray;
}

@end
