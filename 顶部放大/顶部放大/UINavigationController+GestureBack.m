//
//  UINavigationController+GestureBack.m
//  手势返回
//
//  Created by 张江东 on 16/10/21.
//  Copyright © 2016年 58kuaipai. All rights reserved.
//

#import "UINavigationController+GestureBack.h"
#import <objc/runtime.h>


@interface FullScreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation FullScreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    // 判断是否是根控制器，如果是，取消手势
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    
    
//    unsigned int count = 0;
//    Ivar *members = class_copyIvarList([self.navigationController class], &count);
//    for (int i = 0 ; i < count; i++) {
//        Ivar var = members[i];
//        const char *memberName = ivar_getName(var);
//        const char *memberType = ivar_getTypeEncoding(var);
//        NSLog(@"%s----%s", memberName, memberType);
//    }
    


    // 如果正在转场动画，取消手势
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // 判断手指移动方向
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

@end

@implementation UINavigationController (GestureBack)

// 在类被加载到运行时的时候，就会执行,用运行时替换系统的手势方法,这个分类放到项目里就实现了全屏返回功能
+ (void)load {
    
    Method originalMethod = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(jd_pushViewController:animated:));
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)jd_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.jd_popGestureRecognizer]) {
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.jd_popGestureRecognizer];
        
        NSArray *targets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [targets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        
        self.jd_popGestureRecognizer.delegate = [self fullScreenPopGestureRecognizerDelegate];
        [self.jd_popGestureRecognizer addTarget:internalTarget action:internalAction];
        
        // 禁用系统的交互手势
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if (![self.viewControllers containsObject:viewController]) {
        [self jd_pushViewController:viewController animated:animated];
    }
}

- (FullScreenPopGestureRecognizerDelegate *)fullScreenPopGestureRecognizerDelegate {
    // 关于_cmd:每个方法的内部都有一个-cmd,代表着当前方法。
    FullScreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [[FullScreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}


- (UIPanGestureRecognizer *)jd_popGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
    
    if (panGestureRecognizer == nil) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}


@end
