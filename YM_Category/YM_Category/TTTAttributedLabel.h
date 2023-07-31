// TTTAttributedLabel.h
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#pragma mark - 链接标签属性
@class TTTAttributedLabelLink;

/** 垂直对齐方式 */
typedef NS_ENUM(NSInteger, TTTAttributedLabelVerticalAlignment) {
    TTTAttributedLabelVerticalAlignmentCenter   = 0,
    TTTAttributedLabelVerticalAlignmentTop      = 1,
    TTTAttributedLabelVerticalAlignmentBottom   = 2,
};

/** 是否开启删除线（@YES，@NO） */
extern NSString * const kTTTStrikeOutAttributeName;

/** 背景填充颜色。值必须是'CGColorRef'。默认值是'nil'(无填充) */
extern NSString * const kTTTBackgroundFillColorAttributeName;

/** 背景填充的边界。值必须是'UIEdgeInsets'。默认值是'UIEdgeInsetsZero'(无填充) */
extern NSString * const kTTTBackgroundFillPaddingAttributeName;

/** 背景笔划线颜色。值必须是'CGColorRef'。默认值是'nil'(没有笔划) */
extern NSString * const kTTTBackgroundStrokeColorAttributeName;

/** 背景笔划线宽度。值必须是'NSNumber'。默认值是'1.0f' */
extern NSString * const kTTTBackgroundLineWidthAttributeName;

/** 背景角半径。值必须是'NSNumber'。默认值是'5.0f'。 */
extern NSString * const kTTTBackgroundCornerRadiusAttributeName;

@protocol TTTAttributedLabelDelegate;

// 覆盖UILabel @property以同时接受NSString和NSAttributedString
@protocol TTTAttributedLabel <NSObject>
@property (nonatomic, copy) IBInspectable id text;
@end

IB_DESIGNABLE
/**
 'TTTAttributedLabel'是支持'NSAttributedString'的'UILabel'的替代品，以及自动检测和手动添加的URL，地址，电话号码和日期的链接。
 
 ## 'TTTAttributedLabel'和'UILabel'之间的差异
 
 在大多数情况下，'TTTAttributedLabel'的行为就像'UILabel'。
 以下是一些值得注意的例外，其中'TTTAttributedLabel'可能会有不同的表现:
 
 - 'text' - 这个属性现在接受一个'id'类型的参数，它可以是'NSString'或'NSAttributedString'(两种情况下都是可变或不可变的)
 
 - 'attributedText' - 不要直接设置此属性。
  相反，传递一个' NSAttributedString'到'text'。
 
 - 'lineBreakMode' - 当值为'UILineBreakModeHeadTruncation'、'UILineBreakModeTailTruncation'或'UILineBreakModeMiddleTruncation'时，此属性仅显示第一行
 
 - 'modisfontsizetofitwidth' - ios5及以上版本支持，此属性对任何大于0的'numberOfLines'值都有效。
    在ios4中，将'numberOfLines'设置为大于1，'adjustsFontSizeToFitWidth'设置为'YES'可能会导致'sizeToFit'无限期执行。
 
 - 'baselineAdjustment' - 此属性没有影响。
 - 'textAlignment' - 此属性不支持对齐
 - 'NSTextAttachment' - 不支持此字符串属性。
 
任何影响文本或段落样式的属性，如'firstLineIndent'，只在使用“NSString”设置文本时才适用。如果文本设置为'NSAttributedString'，则不应用这些属性。
 
 ### NSCoding
 
 和UILabel一样，TTTAttributedLabel也符合NSCoding。但是，如果构建目标设置为小于ios6.0，则不会对“linkAttributes”和“activeLinkAttributes”进行编码或解码。这是由于试图在字典中复制非对象CoreText值时引发运行时异常造成的。
 
 在设置文本后，标签上的任何属性改变都不会被反映，直到后续调用'setText:'或'setText:afterInheritingLabelAttributesAndConfiguringWithBlock:'。
 也就是说，在这种情况下操作的顺序很重要。例如，如果在设置文本时，标签文本颜色最初是黑色的，那么将文本颜色更改为红色将不会影响标签的显示，直到再次设置文本为止。

 @bug 不建议直接设置'attributedText'，因为在尝试访问之前设置的链接时可能会导致崩溃。相反，调用'setText:'，传递一个'NSAttributedString'。
 */
@interface TTTAttributedLabel : UILabel <TTTAttributedLabel, UIGestureRecognizerDelegate>

/** 指定的初始化器是@c initWithFrame:和@c initWithCoder:
    init不会对许多必需的属性和其他配置进行初始化 */
- (instancetype) init NS_UNAVAILABLE;

///-----------------------------
/// @name Accessing the Delegate
///-----------------------------

/**
接收方的委托
'TTTAttributedLabel'委托通过点击标签中的链接来响应发送的消息。
 您可以使用委托来响应引用URL、地址、电话号码、日期或具有指定时区和持续时间的日期的链接。
*/
@property (nonatomic, unsafe_unretained) id <TTTAttributedLabelDelegate> delegate;

#pragma mark - 检测、访问和样式化链接

/**
'NSTextCheckingType'的位掩码，用于自动检测标签文本中的链接。
在设置'text'之前，您必须指定'enabledTextCheckingTypes'，使用'setText:'或'setText:afterInheritingLabelAttributesAndConfiguringWithBlock:'。
*/
@property (nonatomic, assign) NSTextCheckingTypes enabledTextCheckingTypes;

/** 一个'NSTextCheckingResult'对象数组，用于检测到的链接或手动添加到标签文本中的链接。 */
@property (readonly, nonatomic, strong) NSArray *links;

/**
 正常状态下链接文本的属性风格
 包含默认的“NSAttributedString”属性的字典，其应用于检测到或手动添加到标签文本的链接。
 默认链接样式为蓝色和下划线。
 @warning在设置自动切换或手动添加要应用的这些属性的链接之前，必须指定“linkAttributes”。
 */
@property (nonatomic, strong) NSDictionary *linkAttributes;

/**
 高亮状态下链接文本的属性风格
 包含默认的“NSAttributedString”属性的字典，当它们处于活动状态时应用于链接。
 如果“nil”或空的“NSDictionary”，活动链接将不被设置。 
 默认的活动链接样式是红色和下划线。
 */
@property (nonatomic, strong) NSDictionary *activeLinkAttributes;

/**
 包含默认的“NSAttributedString”属性的字典，当属于处于非活动状态的链接时，这些属性将由iOS 7及更高版本中的“tintColor”的更改触发。
 如果“nil”或空的“NSDictionary”，不活动的链接将不被设置。
 默认的非活动链接样式是灰色和未装饰的。
 */
@property (nonatomic, strong) NSDictionary *inactiveLinkAttributes;

/** 为链接的背景嵌入的边缘。默认值是'{0, -1, 0, -1}' */
@property (nonatomic, assign) UIEdgeInsets linkBackgroundEdgeInset;

/**
 指示是否将在触摸周围的扩展区域内检测到链接
 来模拟WebView的链接检测行为
 默认值是NO。启用此功能可能会对性能产生负面影响
 */
@property (nonatomic, assign) BOOL extendsLinkTouchArea;

#pragma mark - 接受文本样式属性
/**
 标签的阴影半径
 值为0表示没有模糊，而较大的值则相应地产生较大的模糊。这个值不能为负。默认值是0
 */
@property (nonatomic, assign) CGFloat shadowRadius;

/**
 当标签的'highlighted'属性为'YES'时，标签的阴影模糊半径
 值为0表示没有模糊，而较大的值则相应地产生较大的模糊
 这个值不能为负。默认值是0。 */
@property (nonatomic, assign) CGFloat highlightedShadowRadius;

/**
 当标签的'highlighted'属性为'YES'时，标签的阴影偏移量。
 大小为{0,0}表示没有偏移量，正值向下和向右扩展。默认大小是{0,0}
 */
@property (nonatomic, assign) CGSize highlightedShadowOffset;

/**
 当标签的'highlighted'属性为'YES'时，标签的阴影颜色。
 默认值是'nil'(没有阴影颜色)
 */
@property (nonatomic, strong) UIColor *highlightedShadowColor;

/**
 等于kern下一个字符。默认是标准的kerning。
 如果将此属性设置为0.0，则根本不执行kerning。
 */
@property (nonatomic, assign) CGFloat kern;


#pragma mark - 接受段落样式属性
/**
 从帧的前缘到开始的距离，以点为单位
 段落的第一行。这个值总是非负的，默认值是0.0。
 这适用于全文，而不是任何特定的段落度量。
 */
@property (nonatomic, assign) CGFloat firstLineIndent;

/** 行距。这个值总是非负的，默认为0.0。 */
@property (nonatomic, assign) CGFloat lineSpacing;

/** 最小行距。如果值为0.0，则最小行高设置为'font'的行高。0.0默认情况下。 */
@property (nonatomic, assign) CGFloat minimumLineHeight;

/** 最大行距。如果值为0.0，则将最大行高设置为'font'的行高。0.0默认情况下。 */
@property (nonatomic, assign) CGFloat maximumLineHeight;

/** 行距倍数。 默认情况下，此值为1.0。 */
@property (nonatomic, assign) CGFloat lineHeightMultiple;

/**
 从页边距到文本容器的距离，以点为单位。默认值是'UIEdgeInsetsZero'。
 sizeThatFits:将通过这些边距增加其返回的大小。
 drawTextInRect:将通过这些边距插入所有绘制的文本。
 */
@property (nonatomic, assign) IBInspectable UIEdgeInsets textInsets;

/**
 当视图大小大于文本大小时，标签的垂直文本对齐方式
 默认情况下，垂直对齐是'TTTAttributedLabelVerticalAlignmentCenter'
 */
@property (nonatomic, assign) TTTAttributedLabelVerticalAlignment verticalAlignment;

#pragma mark - 标签末尾省略样式
/** 用于标签末尾省略样式的带属性字符串。 */
@property (nonatomic, strong) IBInspectable NSAttributedString *attributedTruncationToken;

#pragma mark - 长按交互
/** 标签内部使用的长按手势识别器 */
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

#pragma mark - 计算带属性字符串的大小
/**
 根据指定的大小和行数约束，计算并返回最适合带属性字符串的大小
 @param attributedString 属性字符串
 @param size 用于计算大小的最大尺寸
 @param numberOfLines 要绘制的文本中的最大行数，如果约束大小不能容纳完整的带属性字符串
 @return 在指定的约束中适合带属性字符串的大小
 */
+ (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attributedString
                       withConstraints:(CGSize)size
                limitedToNumberOfLines:(NSUInteger)numberOfLines;

#pragma mark - 设置文本属性
/**
 设置标签显示的文本
 @param text 由标签显示的'NSString'或'NSAttributedString'对象。
 @discussion 这个方法覆盖'UILabel -setText:'来接受'NSString'和'NSAttributedString'对象。这个字符串默认为'nil'。
 */
- (void)setText:(id)text;

/**
 在配置一个带属性字符串后，设置标签显示的文本，该字符串从block中继承文本属性
 
 @param text 标签显示的'NSString'或'NSAttributedString'对象。
 @param block 一个block对象，它返回一个'NSMutableAttributedString'对象并接受一个参数，它是一个带有第一个参数的文本的'NSMutableAttributedString'对象，以及从标签文本样式继承的文本属性。
        例如，如果您将标签的'font'指定为'[UIFont boldSystemFontOfSize：14]'和'textColor'为
 '[UIColor redColor]'，则该块的`NSAttributedString`参数将包含`NSAttributedString `属性等价物。 在此块中，您可以在特定范围上设置更多属性。
 @discussion 这个字符串默认为'nil'。
 */
- (void)setText:(id)text
afterInheritingLabelAttributesAndConfiguringWithBlock:(NSMutableAttributedString *(^)(NSMutableAttributedString *mutableAttributedString))block;

#pragma mark - 访问文本属性
/**
 标签的当前attributesText的副本。 如果从未在标签上设置过属性字符串，则返回'nil'
 @warning 不要直接设置此属性。 而是将@c文本设置为@c NSAttributedString。
 */
@property (readwrite, nonatomic, copy) NSAttributedString *attributedText;

#pragma mark - 添加链接
/**
 添加链接
 您可以通过创建自己的@c TTTAttributedLabelLink并将其传递给此方法来自定义单个链接的外观和可访问性值
 添加链接的其他方法将使用标签的默认属性。
 
 @warning 必须在调用此方法之前修改链接的属性字典
 @param link @c TTTAttributedLabelLink对象
 */
- (void)addLink:(TTTAttributedLabelLink *)link;

/**
 添加指向@c NSTextCheckingResult的链接
 @param result @c NSTextCheckingResult表示链接的位置和类型
 @return 新添加的链接对象
 */
- (TTTAttributedLabelLink *)addLinkWithTextCheckingResult:(NSTextCheckingResult *)result;

/**
 添加指向@c NSTextCheckingResult的链接
 @param result     @c NSTextCheckingResult表示链接的位置和类型
 @param attributes 要添加到指定链接范围内的文本的属性
                   如果设置，标签的@c activeAttributes和@c inactiveAttributes将应用于链接
                   如果是'nil'，则链接中不会添加任何属性
 @return 新添加的链接对象
 */
- (TTTAttributedLabelLink *)addLinkWithTextCheckingResult:(NSTextCheckingResult *)result
                                               attributes:(NSDictionary *)attributes;

/**
 为指定范围文本标签添加链接
 @param url 要链接的网址
 @param range 文本中链接标签的范围。范围不得超过接收器的范围
 @return 新添加的链接对象
 */
- (TTTAttributedLabelLink *)addLinkToURL:(NSURL *)url
                               withRange:(NSRange)range;

/**
 为指定范围文本标签添加地址链接
 @param addressComponents 要链接到的地址的地址组件字典
 @param range 文本中链接标签的范围。范围不得超过接收器的范围
 @discussion 地址组件字典键在'NSTextCheckingResult'的'地址组件键'中描述。
 @return 新添加的链接对象
 */
- (TTTAttributedLabelLink *)addLinkToAddress:(NSDictionary *)addressComponents
                                   withRange:(NSRange)range;

/**
 为指定范围文本标签添加电话号码链接
 @param phoneNumber 要链接的电话号码
 @param range 文本中链接标签的范围。范围不得超过接收器的范围
 @return 新添加的链接对象
 */
- (TTTAttributedLabelLink *)addLinkToPhoneNumber:(NSString *)phoneNumber
                                       withRange:(NSRange)range;

/**
 为指定范围文本标签添加电话日期链接
 @param date 要链接的日期
 @param range 文本中链接标签的范围。范围不得超过接收器的范围
 @return 新添加的链接对象
 */
- (TTTAttributedLabelLink *)addLinkToDate:(NSDate *)date
                                withRange:(NSRange)range;

/**
 Adds a link to a date with a particular time zone and duration for a specified range in the label text.
 
 @param date The date to be linked to.
 @param timeZone The time zone of the specified date.
 @param duration The duration, in seconds from the specified date.
 @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
 
 @return The newly added link object.
 */
- (TTTAttributedLabelLink *)addLinkToDate:(NSDate *)date
                                 timeZone:(NSTimeZone *)timeZone
                                 duration:(NSTimeInterval)duration
                                withRange:(NSRange)range;

/**
 Adds a link to transit information for a specified range in the label text.

 @param components A dictionary containing the transit components. The currently supported keys are `NSTextCheckingAirlineKey` and `NSTextCheckingFlightKey`.
 @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
 
 @return The newly added link object.
 */
- (TTTAttributedLabelLink *)addLinkToTransitInformation:(NSDictionary *)components
                                              withRange:(NSRange)range;

/**
 Returns whether an @c NSTextCheckingResult is found at the give point.
 
 @discussion This can be used together with @c UITapGestureRecognizer to tap interactions with overlapping views.
 
 @param point The point inside the label.
 */
- (BOOL)containslinkAtPoint:(CGPoint)point;

/**
 Returns the @c TTTAttributedLabelLink at the give point if it exists.
 
 @discussion This can be used together with @c UIViewControllerPreviewingDelegate to peek into links.
 
 @param point The point inside the label.
 */
- (TTTAttributedLabelLink *)linkAtPoint:(CGPoint)point;

@end

/**
 The `TTTAttributedLabelDelegate` protocol defines the messages sent to an attributed label delegate when links are tapped. All of the methods of this protocol are optional.
 */
@protocol TTTAttributedLabelDelegate <NSObject>

///-----------------------------------
/// @name Responding to Link Selection
///-----------------------------------
@optional

/**
 Tells the delegate that the user did select a link to a URL.
 
 @param label The label whose link was selected.
 @param url The URL for the selected link.
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url;

/**
 Tells the delegate that the user did select a link to an address.
 
 @param label The label whose link was selected.
 @param addressComponents The components of the address for the selected link.
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithAddress:(NSDictionary *)addressComponents;

/**
 Tells the delegate that the user did select a link to a phone number.
 
 @param label The label whose link was selected.
 @param phoneNumber The phone number for the selected link.
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber;

/**
 Tells the delegate that the user did select a link to a date.
 
 @param label The label whose link was selected.
 @param date The datefor the selected link.
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
  didSelectLinkWithDate:(NSDate *)date;

/**
 Tells the delegate that the user did select a link to a date with a time zone and duration.
 
 @param label The label whose link was selected.
 @param date The date for the selected link.
 @param timeZone The time zone of the date for the selected link.
 @param duration The duration, in seconds from the date for the selected link.
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
  didSelectLinkWithDate:(NSDate *)date
               timeZone:(NSTimeZone *)timeZone
               duration:(NSTimeInterval)duration;

/**
 Tells the delegate that the user did select a link to transit information

 @param label The label whose link was selected.
 @param components A dictionary containing the transit components. The currently supported keys are `NSTextCheckingAirlineKey` and `NSTextCheckingFlightKey`.
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components;

/**
 Tells the delegate that the user did select a link to a text checking result.
 
 @discussion This method is called if no other delegate method was called, which can occur by either now implementing the method in `TTTAttributedLabelDelegate` corresponding to a particular link, or the link was added by passing an instance of a custom `NSTextCheckingResult` subclass into `-addLinkWithTextCheckingResult:`.
 
 @param label The label whose link was selected.
 @param result The custom text checking result.
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result;

///---------------------------------
/// @name Responding to Long Presses
///---------------------------------

/**
 *  Long-press delegate methods include the CGPoint tapped within the label's coordinate space.
 *  This may be useful on iPad to present a popover from a specific origin point.
 */

/**
 Tells the delegate that the user long-pressed a link to a URL.
 
 @param label The label whose link was long pressed.
 @param url The URL for the link.
 @param point the point pressed, in the label's coordinate space
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithURL:(NSURL *)url
                atPoint:(CGPoint)point;

/**
 Tells the delegate that the user long-pressed a link to an address.
 
 @param label The label whose link was long pressed.
 @param addressComponents The components of the address for the link.
 @param point the point pressed, in the label's coordinate space
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithAddress:(NSDictionary *)addressComponents
                atPoint:(CGPoint)point;

/**
 Tells the delegate that the user long-pressed a link to a phone number.
 
 @param label The label whose link was long pressed.
 @param phoneNumber The phone number for the link.
 @param point the point pressed, in the label's coordinate space
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithPhoneNumber:(NSString *)phoneNumber
                atPoint:(CGPoint)point;


/**
 Tells the delegate that the user long-pressed a link to a date.
 
 @param label The label whose link was long pressed.
 @param date The date for the selected link.
 @param point the point pressed, in the label's coordinate space
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithDate:(NSDate *)date
                atPoint:(CGPoint)point;


/**
 Tells the delegate that the user long-pressed a link to a date with a time zone and duration.
 
 @param label The label whose link was long pressed.
 @param date The date for the link.
 @param timeZone The time zone of the date for the link.
 @param duration The duration, in seconds from the date for the link.
 @param point the point pressed, in the label's coordinate space
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithDate:(NSDate *)date
               timeZone:(NSTimeZone *)timeZone
               duration:(NSTimeInterval)duration
                atPoint:(CGPoint)point;


/**
 Tells the delegate that the user long-pressed a link to transit information.
 
 @param label The label whose link was long pressed.
 @param components A dictionary containing the transit components. The currently supported keys are `NSTextCheckingAirlineKey` and `NSTextCheckingFlightKey`.
 @param point the point pressed, in the label's coordinate space
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithTransitInformation:(NSDictionary *)components
                atPoint:(CGPoint)point;

/**
 Tells the delegate that the user long-pressed a link to a text checking result.
 
 @discussion Similar to `-attributedLabel:didSelectLinkWithTextCheckingResult:`, this method is called if a link is long pressed and the delegate does not implement the method corresponding to this type of link.
 
 @param label The label whose link was long pressed.
 @param result The custom text checking result.
 @param point the point pressed, in the label's coordinate space
 */
- (void)attributedLabel:(TTTAttributedLabel *)label
didLongPressLinkWithTextCheckingResult:(NSTextCheckingResult *)result
                atPoint:(CGPoint)point;

@end

@interface TTTAttributedLabelLink : NSObject <NSCoding>

typedef void (^TTTAttributedLabelLinkBlock) (TTTAttributedLabel *, TTTAttributedLabelLink *);

/**
 An `NSTextCheckingResult` representing the link's location and type.
 */
@property (readonly, nonatomic, strong) NSTextCheckingResult *result;

/**
 A dictionary containing the @c NSAttributedString attributes to be applied to the link.
 */
@property (readonly, nonatomic, copy) NSDictionary *attributes;

/**
 A dictionary containing the @c NSAttributedString attributes to be applied to the link when it is in the active state.
 */
@property (readonly, nonatomic, copy) NSDictionary *activeAttributes;

/**
 A dictionary containing the @c NSAttributedString attributes to be applied to the link when it is in the inactive state, which is triggered by a change in `tintColor` in iOS 7 and later.
 */
@property (readonly, nonatomic, copy) NSDictionary *inactiveAttributes;

/**
 Additional information about a link for VoiceOver users. Has default values if the link's @c result is @c NSTextCheckingTypeLink, @c NSTextCheckingTypePhoneNumber, or @c NSTextCheckingTypeDate.
 */
@property (nonatomic, copy) NSString *accessibilityValue;

/**
 A block called when this link is tapped.
 If non-nil, tapping on this link will call this block instead of the 
 @c TTTAttributedLabelDelegate tap methods, which will not be called for this link.
 */
@property (nonatomic, copy) TTTAttributedLabelLinkBlock linkTapBlock;

/**
 A block called when this link is long-pressed.
 If non-nil, long pressing on this link will call this block instead of the
 @c TTTAttributedLabelDelegate long press methods, which will not be called for this link.
 */
@property (nonatomic, copy) TTTAttributedLabelLinkBlock linkLongPressBlock;

/**
 使用指定的属性字典初始化链接。
  
 @param attributes          链接的@c attributes属性。
 @param activeAttributes    链接的@c activeAttributes属性。
 @param inactiveAttributes  链接的@c inactiveAttributes属性。
 @param result              一个@c NSTextCheckingResult，表示链接的位置和类型。
  
 @return初始化的链接对象。
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes
                  activeAttributes:(NSDictionary *)activeAttributes
                inactiveAttributes:(NSDictionary *)inactiveAttributes
                textCheckingResult:(NSTextCheckingResult *)result;

/**
 Initializes a link using the attribute dictionaries set on a specified label.
 
 @param label  The attributed label from which to inherit attribute dictionaries.
 @param result An @c NSTextCheckingResult representing the link's location and type.
 
 @return The initialized link object.
 */
- (instancetype)initWithAttributesFromLabel:(TTTAttributedLabel*)label
                         textCheckingResult:(NSTextCheckingResult *)result;

@end
