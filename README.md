# MRLogicInjection

[![CI Status](http://img.shields.io/travis/stonedong/MRLogicInjection.svg?style=flat)](https://travis-ci.org/stonedong/MRLogicInjection)
[![Version](https://img.shields.io/cocoapods/v/MRLogicInjection.svg?style=flat)](http://cocoapods.org/pods/MRLogicInjection)
[![License](https://img.shields.io/cocoapods/l/MRLogicInjection.svg?style=flat)](http://cocoapods.org/pods/MRLogicInjection)
[![Platform](https://img.shields.io/cocoapods/p/MRLogicInjection.svg?style=flat)](http://cocoapods.org/pods/MRLogicInjection)

## 介绍
仿照KVO实现原理，构建AOP编程模式，中逻辑注入的基础组件库。核心机制复杂，但是代码简单。主要依赖isa-swizzing和method-swizzing两项技术。该库主要针对于instance的业务逻辑注入，只对一个内存实例生效。而不是一整个类别。因而，具有场景化的特点，不会造成类污染。只需要在需要特定场景中的特定实例上使用该库就OK。


## 安装

MRLogicInjection is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MRLogicInjection"
```

## 功能点

1. AOP对类实例进行业务逻辑注入
2. 支持嵌套业务逻辑注入

### 计划中
1. 注入的类中的property属性，自动使用辅助变量存储。

## 使用例子

参照使用该库解决延迟点击的问题：[DZDeneyRepeat](https://github.com/yishuiliunian/DZDeneyRepeat)

To run the example project, clone the repo, and run `pod install` from the Example directory first.


### 选取合适的注入点进行业务逻辑编制

在解决重复点击的问题中，使用

~~~
- (void) sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
~~~

为注入点，因为所有的UIControl的时间响应都经由此处。

围绕该注入点构建DZDeneyRepeatInjection类，该类包含了关于重复点击问题的所有相关逻辑。

~~~


@interface DZDeneyRepeatInjection : UIControl
@property (nonatomic, assign) float denyRepeatTime;
@end


static void* kDZDeneyRepeatTimeKey = &kDZDeneyRepeatTimeKey;
@implementation DZDeneyRepeatInjection

- (void) setDenyRepeatTime:(float)denyRepeatTime
{
    objc_setAssociatedObject(self, kDZDeneyRepeatTimeKey, @(denyRepeatTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float) denyRepeatTime
{
    NSNumber* num = objc_getAssociatedObject(self, kDZDeneyRepeatTimeKey);
    if (!num) {
        return 0.0f;
    }
    return [num floatValue];
}
- (void) sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    [super sendAction:action to:target forEvent:event];
    if (self.denyRepeatTime > 0.00001) {
        self.userInteractionEnabled = NO;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.denyRepeatTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.userInteractionEnabled = YES;
        });
    }
}
@end
~~~

然后使用MRLogicInjection构建业务逻辑注入的辅助方法：

~~~

DZDeneyRepeatInjection* DZInjectionDeneyRepeatLogic(UIControl* object, float deneyTime)
{
    DZDeneyRepeatInjection* deney = MRExtendInstanceLogic(object, @[DZDeneyRepeatInjection.class]);
    if ([deney respondsToSelector:@selector(setDenyRepeatTime:)]) {
        [deney setDenyRepeatTime:deneyTime];
    }
    return deney;
}
~~~

在特定的页面中对需要防止重复点击的UIControl类进行注入：

~~~
DZInjectionDeneyRepeatLogic(anButton, 10);
~~~

之后这个实例anButton就具有的防止重复点击的能力，而不影响该类的其他实例。



# Author

stonedong, yishuiliunian@gmail.com

## License

MRLogicInjection is available under the MIT license. See the LICENSE file for more info.
