//
//  ViewController.m
//  OEM-Tools
//
//  Created by zhoujianfeng on 16/3/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

#import "ViewController.h"
#import "DJActivityIndicator.h"
#import "DJProgressIndicator.h"
#import "DJProgressHUD.h"

// 文件协议头长度
#define delegateLength 7

#define projectIconPrefix @"PayChinaPospIOS/Assets.xcassets/AppIcon.appiconset/"
#define projectLaunchPrefix @"PayChinaPospIOS/Assets.xcassets/Brand Assets.launchimage/"

#define icon29x2 @"AppIcon29x29@2x.png"
#define icon29x3 @"AppIcon29x29@3x.png"
#define icon40x2 @"AppIcon40x40@2x.png"
#define icon40x3 @"AppIcon40x40@3x.png"
#define icon60x2 @"AppIcon60x60@2x.png"
#define icon60x3 @"AppIcon60x60@3x.png"

#define launch480 @"Default-480h@2x.png"
#define launch568 @"LaunchImage-700-568h@2x.png"
#define launch667 @"LaunchImage-800-667h@2x.png"
#define launch736 @"LaunchImage-800-736h@3x.png"

#define app_logo @"app_logo_icon@2x.png"
#define app_name @"app_name_img@2x.png"
#define read_card @"read_card_help@2x.png"
#define weixin @"weixin@2x.png"

#define InfoPlist @"PayChinaPospIOS/Info.plist"
#define configFle @"PayChinaPospIOS/Classes/Application/Common.h"
#define packageScript @"archive.sh"

#define app_logo_path [NSString stringWithFormat:@"PayChinaPospIOS/Assets.xcassets/OEM/%@.imageset/",[app_logo substringWithRange:NSMakeRange(0, app_logo.length - 7)]]
#define app_name_path [NSString stringWithFormat:@"PayChinaPospIOS/Assets.xcassets/OEM/%@.imageset/",[app_name substringWithRange:NSMakeRange(0, app_name.length - 7)]]
#define read_card_path [NSString stringWithFormat:@"PayChinaPospIOS/Assets.xcassets/OEM/%@.imageset/",[read_card substringWithRange:NSMakeRange(0, read_card.length - 7)]]
#define weixin_path [NSString stringWithFormat:@"PayChinaPospIOS/Assets.xcassets/OEM/%@.imageset/",[weixin substringWithRange:NSMakeRange(0, weixin.length - 7)]]

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSButton *selectProjectButton;
@property (weak) IBOutlet NSTextField *projectLabel;

@property (weak) IBOutlet NSButton *selectConfigureButton;
@property (weak) IBOutlet NSTextField *configureLabel;

@property (weak) IBOutlet NSTextField *appNameField;
@property (weak) IBOutlet NSTextField *appBundleIdentifierField;
@property (weak) IBOutlet NSTextField *appVersionField;
@property (weak) IBOutlet NSTextField *channelIdentifierField; // 渠道标识 1、嘀付 2、速易通 3、聚米 4、量子支付 5、鹏程i付 6、云付通 7、卡卡乐刷
@property (weak) IBOutlet NSTextField *appDomainField;
@property (weak) IBOutlet NSTextField *appTelephoneField;
@property (weak) IBOutlet NSTextField *homeTitleField;
@property (weak) IBOutlet NSTextField *weixinAccountField;

@property (weak) IBOutlet NSButton *produceSwitch; // 是否打包生产环境
@property (weak) IBOutlet NSPopUpButtonCell *OEMSelectPopUpButton;

@property (weak) IBOutlet NSTextField *ipaNameField;
@property (weak) IBOutlet NSTextField *exportPathLabel;
@property (weak) IBOutlet NSTextField *profileNameField;
@property (weak) IBOutlet NSTextField *keychainPasswordField;
@property (weak) IBOutlet NSTextField *currentUserNameField;
@property (weak) IBOutlet NSTextField *currentPasswordField;

@property (weak) IBOutlet NSPopUpButtonCell *selectOEMButton;

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSMutableArray *results;      // 操作信息

@property (nonatomic, copy) NSString *signString;           // OEM标识符

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置默认值
    [self setupOENConfigWithItem:0];
}

/**
 *  保存当前配置
 */
- (IBAction)didTappedSaveConfigButton:(NSButton *)button
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"您确定要保存所有OEM配置信息吗？" defaultButton:@"确定" alternateButton:@"取消" otherButton:nil informativeTextWithFormat:@"保存后会更新所有OEM原有配置，方便下一次直接使用"];
    
    if([alert runModal] == NSAlertDefaultReturn) {
        [self saveData];
    }
}

/**
 *  清除列表
 */
- (IBAction)cleanList:(NSButton *)sender
{
    [self.results removeAllObjects];
    [self.tableView reloadData];
}

/**
 *  根据选择OEM，加载配置信息
 */
- (IBAction)didSelectPopUpButton:(NSPopUpButtonCell *)button
{
    // 根据选择OEM，初始化默认配置
    [self setupOENConfigWithItem:button.indexOfSelectedItem];
    
    // 替换配置
    [self setupAllConfig];
}

/**
 *  设置OEM
 */
- (void)setupOENConfigWithItem:(NSInteger)item
{
    switch (item) {
        case 0:
            [self setupDifu];
            break;
        case 1:
            [self setupJumi];
            break;
        case 2:
            [self setupKakaleshua];
            break;
        case 3:
            [self setupChengqianbao];
            break;
        case 4:
            [self setupSuyitong];
            break;
        case 5:
            [self setupYunfutong];
            break;
        default:
            break;
    }

}

/**
 *  选择路径
 */
- (IBAction)didTappedSelectButton:(NSButton *)button
{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    
    if ([openDlg runModal]) {
        
        NSURL *fileURL = [openDlg URL];
        NSURL *directoryURL = [openDlg directoryURL];
        
        switch (button.tag) {
            case 10:
                self.projectLabel.stringValue = [directoryURL relativeString];
                break;
            case 11:
                self.configureLabel.stringValue = [fileURL relativeString];
                break;
            case 12:
                self.exportPathLabel.stringValue = [fileURL relativeString];
                break;
            default:
                break;
        }
    }
}

/**
 *  更新配置信息
 */
- (void)setupAllConfig
{
    // 替换AppIcon
    NSArray *icons = @[icon29x2, icon29x3, icon40x2, icon40x3, icon60x2, icon60x3];
    for (NSString *iconName in icons) {
        if ([self replaceFileWithSrc:[self.configureLabel.stringValue stringByAppendingString:iconName] destination:[self.projectLabel.stringValue stringByAppendingString:[projectIconPrefix stringByAppendingString:iconName]]]) {
            // 成功后加入数据源数组
            [self.results addObject:[NSString stringWithFormat:@"替换【AppIcon】OK"]];
        } else {
            [self.results addObject:[NSString stringWithFormat:@"替换【AppIcon】NO"]];
        }
    }
    
    // 替换LaunchImage
    NSArray *launchs = @[launch480, launch568, launch667, launch736];
    for (NSString *launchName in launchs) {
        if ([self replaceFileWithSrc:[self.configureLabel.stringValue stringByAppendingString:launchName] destination:[self.projectLabel.stringValue stringByAppendingString:[projectLaunchPrefix stringByAppendingString:launchName]]]) {
            // 成功后加入数据源数组
            [self.results addObject:[NSString stringWithFormat:@"替换【LaunchImage】OK"]];
        } else {
            [self.results addObject:[NSString stringWithFormat:@"替换【LaunchImage】NO"]];
        }
    }
    
    // 替换OEM素材
    NSArray *oems = @[@{app_logo : app_logo_path}, @{app_name : app_name_path}, @{read_card : read_card_path}, @{weixin : weixin_path}];
    for (int i = 0; i < oems.count; i++) {
        NSDictionary *oemDict = oems[i];
        
        NSString *src = [self.configureLabel.stringValue stringByAppendingString:oemDict.allKeys[0]];
        NSString *destination = [self.projectLabel.stringValue stringByAppendingString:[oemDict[oemDict.allKeys[0]] stringByAppendingString:oemDict.allKeys[0]]];
        
        if ([self replaceFileWithSrc:src destination:destination]) {
            // 成功后加入数据源数组
            [self.results addObject:[NSString stringWithFormat:@"替换【OEM素材】OK"]];
        } else {
            [self.results addObject:[NSString stringWithFormat:@"替换【OEM素材】NO"]];
        }
    }
    
    // Info.plist路径
    NSString *infoPlist_path = [self.projectLabel.stringValue stringByAppendingString:InfoPlist];
    
    // 替换app名称
    if ([self replaceConfigStringWithSrc:infoPlist_path Pattern:@"(?<=CFBundleDisplayName</key>)(\n\\s*)<string>(.*?)</string>" template:[NSString stringWithFormat:@"\n\t<string>%@</string>", self.appNameField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【app名称】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【app名称】NO"]];
    }
    
    // 替换app版本号
    if ([self replaceConfigStringWithSrc:infoPlist_path Pattern:@"(?<=CFBundleShortVersionString</key>)(\n\\s*)<string>(.*?)</string>" template:[NSString stringWithFormat:@"\n\t<string>%@</string>", self.appVersionField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【app版本号】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【app版本号】NO"]];
    }
    
    // 替换app bundle identifier
    if ([self replaceConfigStringWithSrc:infoPlist_path Pattern:@"(?<=CFBundleIdentifier</key>)(\n\\s*)<string>(.*?)</string>" template:[NSString stringWithFormat:@"\n\t<string>%@</string>", self.appBundleIdentifierField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【app bundle identifier】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【app bundle identifier】NO"]];
    }
    
    NSString *configFile_path = [self.projectLabel.stringValue stringByAppendingString:configFle];
    
    // 替换渠道标识
    if ([self replaceConfigStringWithSrc:configFile_path Pattern:@"(?<=#define channelIdentifier )(@\"(\\d)\")" template:[NSString stringWithFormat:@"@\"%@\"", self.channelIdentifierField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【渠道标识】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【渠道标识】NO"]];
    }
    
    // 替换appName
    if ([self replaceConfigStringWithSrc:configFile_path Pattern:@"(?<=#define appName )(@\"(.*?)\")" template:[NSString stringWithFormat:@"@\"%@\"", self.appNameField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【app名称】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【app名称】NO"]];
    }
    
    // 替换APP域名
    if ([self replaceConfigStringWithSrc:configFile_path Pattern:@"(?<=#define appDomain )(@\"(.*?)\")" template:[NSString stringWithFormat:@"@\"%@\"", self.appDomainField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【APP域名】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【APP域名】NO"]];
    }
    
    // 替换电话号码
    if ([self replaceConfigStringWithSrc:configFile_path Pattern:@"(?<=#define appTelephone )(@\"(.*?)\")" template:[NSString stringWithFormat:@"@\"%@\"", self.appTelephoneField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【电话号码】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【电话号码】NO"]];
    }
    
    // 替换首页顶部标题
    if ([self replaceConfigStringWithSrc:configFile_path Pattern:@"(?<=#define homeTitle )(@\"(.*?)\")" template:[NSString stringWithFormat:@"@\"%@\"", self.homeTitleField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【首页顶部标题】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【首页顶部标题】NO"]];
    }
    
    // 替换微信公众号
    if ([self replaceConfigStringWithSrc:configFile_path Pattern:@"(?<=#define weixinAccount )(@\"(.*?)\")" template:[NSString stringWithFormat:@"@\"%@\"", self.weixinAccountField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【微信公众号】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【微信公众号】NO"]];
    }
    
    // 是否打包生产
    if ([self replaceConfigStringWithSrc:configFile_path Pattern:@"(?<=#define TestEnvironment )((\\d))" template:[NSString stringWithFormat:@"%@", self.produceSwitch.state ? @"1" : @"0"]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【生产控制标识】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【生产控制标识】NO"]];
    }
    
    // 打包脚本路径
    NSString *scriptPath = [self.projectLabel.stringValue stringByAppendingString:packageScript];
    
    // ipa包名
    if ([self replaceConfigStringWithSrc:scriptPath Pattern:@"(?<=IPA_NAME=)(\"(.*?)\")" template:[NSString stringWithFormat:@"\"%@%@\"",self.ipaNameField.stringValue, self.appVersionField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【ipa包名】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【ipa包名】NO"]];
    }
    
    // ipa导出路径
    if ([self replaceConfigStringWithSrc:scriptPath Pattern:@"(?<=APP_DIR=)(\"(.*?)\")" template:[NSString stringWithFormat:@"\"%@\"", [self getPathWithfileString:self.exportPathLabel.stringValue]]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【ipa导出路径】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【ipa导出路径】NO"]];
    }
    
    // 项目路径
    if ([self replaceConfigStringWithSrc:scriptPath Pattern:@"(?<=PROJECT_DIR=)(\"(.*?)\")" template:[NSString stringWithFormat:@"\"%@\"", [self getPathWithfileString:self.projectLabel.stringValue]]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【打包项目路径】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【打包项目路径】NO"]];
    }
    
    // profile name
    if ([self replaceConfigStringWithSrc:scriptPath Pattern:@"(?<=PROFILE_NAME=)(\"(.*?)\")" template:[NSString stringWithFormat:@"\"%@\"",self.profileNameField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【Profile name】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【Profile name】NO"]];
    }
    
    // keychain password
    if ([self replaceConfigStringWithSrc:scriptPath Pattern:@"(?<=LOGIN_PASSWORD=)(\"(.*?)\")" template:[NSString stringWithFormat:@"\"%@\"",self.keychainPasswordField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【keychain password】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【keychain password】NO"]];
    }
    
    // bundle identifier
    if ([self replaceConfigStringWithSrc:scriptPath Pattern:@"(?<=PRODUCT_BUNDLE_IDENTIFIER=)(\"(.*?)\")" template:[NSString stringWithFormat:@"\"%@\"",self.appBundleIdentifierField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【bundle identifier】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【bundle identifier】NO"]];
    }
    
    // 替换用户名
    if ([self replaceConfigStringWithSrc:scriptPath Pattern:@"(?<=USER_NAME=)(\"(.*?)\")" template:[NSString stringWithFormat:@"\"%@\"",self.currentUserNameField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【本机用户名】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【本机用户名】NO"]];
    }
    
    // 替换密码
    if ([self replaceConfigStringWithSrc:scriptPath Pattern:@"(?<=PASS_WORD=)(\"(.*?)\")" template:[NSString stringWithFormat:@"\"%@\"",self.currentPasswordField.stringValue]]) {
        // 成功后加入数据源数组
        [self.results addObject:[NSString stringWithFormat:@"替换【本机密码】OK"]];
    } else {
        [self.results addObject:[NSString stringWithFormat:@"替换【本机密码】NO"]];
    }
    
    // 刷新操作信息
    [self.tableView reloadData];
    
    // 滚动到最后一行
    [self.tableView scrollRowToVisible:self.results.count - 1];
}

/**
 *  打包单个OEM
 */
- (IBAction)didTappedPackageButton:(NSButton *)button
{
    // 先替换配置
    [self setupAllConfig];
    
    [DJProgressHUD showStatus:@"正在打包，请稍等片刻..." FromView:self.view];
    // 执行打包操作
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *path = [self.projectLabel.stringValue stringByAppendingString:packageScript];
        NSError *error = nil;
        NSString *commandString = [NSString stringWithContentsOfFile:[self getPathWithfileString:path] encoding:NSUTF8StringEncoding error:&error];
        system([commandString UTF8String]);
        NSLog(@"path = %@",path);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [DJProgressHUD dismiss];
        });
        
        // 打开ipa包目录
        system([[@"open " stringByAppendingString:[self getPathWithfileString:self.exportPathLabel.stringValue]] UTF8String]);
    });
    
}

/**
 *  一键打包所有OEM
 */
- (IBAction)didTappedAllPackageButton:(NSButton *)button
{
    [DJProgressHUD showStatus:@"正在打包，请稍等片刻..." FromView:self.view];
    for (int i = 0; i < self.OEMSelectPopUpButton.numberOfItems; i++) {
        
        // 选择OEM
        [self.OEMSelectPopUpButton selectItemAtIndex:i];
        [self didSelectPopUpButton:self.OEMSelectPopUpButton];
        
        
        NSString *path = [self.projectLabel.stringValue stringByAppendingString:packageScript];
        NSError *error = nil;
        NSString *commandString = [NSString stringWithContentsOfFile:[self getPathWithfileString:path] encoding:NSUTF8StringEncoding error:&error];
        system([commandString UTF8String]);
        NSLog(@"path = %@",path);
    }
    [DJProgressHUD dismiss];
    
    // 打开ipa包目录
    system([[@"open " stringByAppendingString:[self getPathWithfileString:self.exportPathLabel.stringValue]] UTF8String]);
}


/**
 *  匹配字符串中的结果并替换
 *
 *  @param src      需要操作的文件路径   带file://协议
 *  @param pattern  正则字符串
 *  @param template 替换字符串
 */
- (BOOL)replaceConfigStringWithSrc:(NSString *)src Pattern:(NSString *)pattern template:(NSString *)template
{
    NSString *scrPath = [self getPathWithfileString:src];
    NSURL *srcURL = [NSURL fileURLWithPath:scrPath];
    
    if (!srcURL) {
        [self.results addObject:[NSString stringWithFormat:@"URL为空 %@",src]];
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:scrPath];
    
    NSData *data = [file readDataToEndOfFile];
    NSString *xmlString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *result = [regex firstMatchInString:xmlString options:0 range:NSMakeRange(0, xmlString.length)];
    if (result) {
        
        // 替换匹配结果
        xmlString = [regex stringByReplacingMatchesInString:xmlString options:0 range:NSMakeRange(0, xmlString.length) withTemplate:template];
        
        // 文件已经存在，则先删除
        if ([fileManager fileExistsAtPath:scrPath]) {
            NSError *error = nil;
            [fileManager removeItemAtURL:srcURL error:&error];
            if (error) {
                return NO;
            } else {
                // 重新创建文件
                if ([fileManager createFileAtPath:scrPath contents:[xmlString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil]) {
                    return YES;
                } else {
                    return NO;
                }
            }
            
        } else {
            // 重新创建文件
            if ([fileManager createFileAtPath:scrPath contents:[xmlString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil]) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    
    return NO;
}

/**
 *  复制文件操作
 *
 *  @param src         原文件路径        带file://协议
 *  @param destination 目的地文件路径     带file://协议
 *
 *  @return 返回是否复制成功
 */
- (BOOL)replaceFileWithSrc:(NSString *)src destination:(NSString *)destination
{
    NSString *scrPath = [self getPathWithfileString:src];
    NSURL *srcURL = [NSURL fileURLWithPath:scrPath];
    
    NSString *destinationPath = [self getPathWithfileString:destination];
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    
    if (!srcURL || !destinationURL) {
        [self.results addObject:[NSString stringWithFormat:@"URL为空 %@",src]];
        [self.results addObject:[NSString stringWithFormat:@"URL为空 %@",destination]];
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 判断目标文件是否存在，如果已经存在则先删除目标文件，再复制
    if ([fileManager fileExistsAtPath:destinationPath]) {
        
        NSError *error = nil;
        [fileManager removeItemAtURL:destinationURL error:&error];
        if (error) {
            return NO;
        } else {
            // 复制前先判断原文件是否存在，如果存在则复制，不存在则复制失败
            if ([fileManager fileExistsAtPath:scrPath]) {
                NSError *error = nil;
                [fileManager copyItemAtURL:srcURL toURL:destinationURL error:&error];
                
                if (error) {
                    return NO;
                } else {
                    return YES;
                }
            } else {
                return NO;
            }
            
        }
        
    } else {
        
        // 复制前先判断原文件是否存在，如果存在则复制，不存在则复制失败
        if ([fileManager fileExistsAtPath:scrPath]) {
            
            NSError *error = nil;
            [fileManager copyItemAtURL:srcURL toURL:destinationURL error:&error];
            
            if (error) {
                return NO;
            } else {
                return YES;
            }
        } else {
            return NO;
        }
    }
    
}

/**
 *  去掉file://协议头
 *
 *  @param fileString 带协议头的路径
 *
 *  @return 返回去掉协议头的路径
 */
- (NSString *)getPathWithfileString:(NSString *)fileString
{
    return [fileString substringWithRange:NSMakeRange(delegateLength, fileString.length - delegateLength)];
}

#pragma mark - OEM默认配置
/**
 *  嘀付配置项
 */
- (void)setupDifu
{
    self.appVersionField.stringValue = @"2.0.0";
    self.appBundleIdentifierField.stringValue = @"com.aiarm.www";
    self.channelIdentifierField.stringValue = @"1";
    self.appNameField.stringValue = @"嘀付";
    self.appDomainField.stringValue = @"www.xy35.com";
    self.appTelephoneField.stringValue = @"400-615-8825";
    self.homeTitleField.stringValue = @"嘀付-理财版";
    self.weixinAccountField.stringValue = @"aiarmpay";
    self.configureLabel.stringValue = @"file:///Users/feng/Desktop/OEM/difu/";
    self.ipaNameField.stringValue = @"difu";
    self.profileNameField.stringValue = @"mypaychinaapp";
    
    [self reSetupFieldWithSignString:@"difu"];
}

/**
 *  聚米配置项
 */
- (void)setupJumi
{
    self.appVersionField.stringValue = @"2.0.3";
    self.appBundleIdentifierField.stringValue = @"com.aiarm.jumi";
    self.channelIdentifierField.stringValue = @"3";
    self.appNameField.stringValue = @"聚米";
    self.appDomainField.stringValue = @"zhifu.jumi365.com";
    self.appTelephoneField.stringValue = @"400-808-7079";
    self.homeTitleField.stringValue = @"聚米-理财版";
    self.weixinAccountField.stringValue = @"";
    self.configureLabel.stringValue = @"file:///Users/feng/Desktop/OEM/jumi/";
    self.ipaNameField.stringValue = @"jumi";
    self.profileNameField.stringValue = @"jumi_distribution";
    
    [self reSetupFieldWithSignString:@"jumi"];
}

/**
 *  卡卡乐刷配置项
 */
- (void)setupKakaleshua
{
    self.appVersionField.stringValue = @"2.0.0";
    self.appBundleIdentifierField.stringValue = @"com.aiarm.kakale";
    self.channelIdentifierField.stringValue = @"7";
    self.appNameField.stringValue = @"卡卡乐刷";
    self.appDomainField.stringValue = @"kaka.alllpay.com";
    self.appTelephoneField.stringValue = @"400-036-6772";
    self.homeTitleField.stringValue = @"卡卡乐刷";
    self.weixinAccountField.stringValue = @"";
    self.configureLabel.stringValue = @"file:///Users/feng/Desktop/OEM/kakaleshua/";
    self.ipaNameField.stringValue = @"kakaleshua";
    self.profileNameField.stringValue = @"kakale_distribution";
    
    [self reSetupFieldWithSignString:@"kakaleshua"];
}

/**
 *  诚钱包配置
 */
- (void)setupChengqianbao
{
    self.appVersionField.stringValue = @"2.0.0";
    self.appBundleIdentifierField.stringValue = @"com.aiarm.chengqiaobao";
    self.channelIdentifierField.stringValue = @"8";
    self.appNameField.stringValue = @"诚钱包";
    self.appDomainField.stringValue = @"";
    self.appTelephoneField.stringValue = @"400-6649-666";
    self.homeTitleField.stringValue = @"诚钱包";
    self.weixinAccountField.stringValue = @"";
    self.configureLabel.stringValue = @"file:///Users/feng/Desktop/OEM/chengqianbao/";
    self.ipaNameField.stringValue = @"chengqianbao";
    self.profileNameField.stringValue = @"chengqiaobao_distribution";
    
    [self reSetupFieldWithSignString:@"chengqiaobao"];
}

/**
 *  速易通配置项
 */
- (void)setupSuyitong
{
    self.appVersionField.stringValue = @"2.0.0";
    self.appBundleIdentifierField.stringValue = @"com.aiarm.syt";
    self.channelIdentifierField.stringValue = @"2";
    self.appNameField.stringValue = @"速易通";
    self.appDomainField.stringValue = @"suxun.alllpay.com";
    self.appTelephoneField.stringValue = @"400-683-6985";
    self.homeTitleField.stringValue = @"速易通";
    self.weixinAccountField.stringValue = @"";
    self.configureLabel.stringValue = @"file:///Users/feng/Desktop/OEM/suyitong/";
    self.ipaNameField.stringValue = @"suyitong";
    self.profileNameField.stringValue = @"suyitong_distribution";
    
    [self reSetupFieldWithSignString:@"suyitong"];
}

/**
 *  云付通配置项
 */
- (void)setupYunfutong
{
    self.appVersionField.stringValue = @"2.0.0";
    self.appBundleIdentifierField.stringValue = @"com.aiarm.yunfutong";
    self.channelIdentifierField.stringValue = @"6";
    self.appNameField.stringValue = @"云付通";
    self.appDomainField.stringValue = @"penghong.alllpay.com";
    self.appTelephoneField.stringValue = @"400-085-3882";
    self.homeTitleField.stringValue = @"云付通";
    self.weixinAccountField.stringValue = @"";
    self.configureLabel.stringValue = @"file:///Users/feng/Desktop/OEM/yunfutong/";
    self.ipaNameField.stringValue = @"yunfutong";
    self.profileNameField.stringValue = @"yunfutong_distribution";
    
    [self reSetupFieldWithSignString:@"yunfutong"];
}

/**
 *  重新赋值所有文本框
 */
- (void)reSetupFieldWithSignString:(NSString *)signString
{
    self.projectLabel.stringValue = @"file:///Users/feng/Work/PayChinaPospIOS/PayChinaPospIOS/";
    self.exportPathLabel.stringValue = @"file:///Users/feng/Desktop/";
    self.keychainPasswordField.stringValue = @"44334512";
    self.currentUserNameField.stringValue = @"feng";
    self.currentPasswordField.stringValue = @"44334512";
    
    self.signString = signString;
    
    // 获取缓存数据
    [self getData];
}

/**
 *  重置配置
 */
- (IBAction)resetData:(NSButton *)sender
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"您确定要重置所有配置吗？" defaultButton:@"确定" alternateButton:@"取消" otherButton:nil informativeTextWithFormat:@"重置后会恢复默认配置"];
    
    if([alert runModal] == NSAlertDefaultReturn) {
        NSArray *array = @[@"difu", @"jumi", @"kakaleshua", @"chengqiaobao", @"suyitong", @"yunfutong"];
        for (NSString *signString in array) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:signString];
        }
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"commonConfig"];
        
        // 恢复当前选择的OEM默认设置
        [self didSelectPopUpButton:self.selectOEMButton];
    }
    
}

/**
 *  根据标识符来获取配置
 */
- (void)getData
{
    // 判断本地是否有缓存数据，如果有则加载缓存，没有则赋值默认值
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:self.signString];
    
    // 如果有缓存数据就用缓存数据
    if (dict) {
        self.appVersionField.stringValue = dict[@"appVersionField"];
        self.appBundleIdentifierField.stringValue = dict[@"appBundleIdentifierField"];
        self.channelIdentifierField.stringValue = dict[@"channelIdentifierField"];
        self.appNameField.stringValue = dict[@"appNameField"];
        self.appDomainField.stringValue = dict[@"appDomainField"];
        self.appTelephoneField.stringValue = dict[@"appTelephoneField"];
        self.homeTitleField.stringValue = dict[@"homeTitleField"];
        self.weixinAccountField.stringValue = dict[@"weixinAccountField"];
        self.configureLabel.stringValue = dict[@"configureLabel"];
        self.ipaNameField.stringValue = dict[@"ipaNameField"];
        self.profileNameField.stringValue = dict[@"profileNameField"];
    }
    
    // 获取公共配置
    NSDictionary *commonDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"commonConfig"];
    if (commonDict) {
        self.projectLabel.stringValue = commonDict[@"projectLabel"];
        self.keychainPasswordField.stringValue = commonDict[@"keychainPasswordField"];
        self.currentUserNameField.stringValue = commonDict[@"currentUserNameField"];
        self.currentPasswordField.stringValue = commonDict[@"currentPasswordField"];
        self.exportPathLabel.stringValue = commonDict[@"exportPathLabel"];
    }
}

/**
 *  根据标识符保存配置
 */
- (void)saveData
{
    NSMutableDictionary *muDict = [NSMutableDictionary dictionary];
    // 重新缓存数据
    muDict[@"appVersionField"] = self.appVersionField.stringValue;
    muDict[@"appBundleIdentifierField"] = self.appBundleIdentifierField.stringValue;
    muDict[@"channelIdentifierField"] = self.channelIdentifierField.stringValue;
    muDict[@"appNameField"] = self.appNameField.stringValue;
    muDict[@"appDomainField"] = self.appDomainField.stringValue;
    muDict[@"appTelephoneField"] = self.appTelephoneField.stringValue;
    muDict[@"homeTitleField"] = self.homeTitleField.stringValue;
    muDict[@"weixinAccountField"] = self.weixinAccountField.stringValue;
    muDict[@"configureLabel"] = self.configureLabel.stringValue;
    muDict[@"ipaNameField"] = self.ipaNameField.stringValue;
    muDict[@"profileNameField"] = self.profileNameField.stringValue;
    [[NSUserDefaults standardUserDefaults] setObject:muDict forKey:self.signString];
    
    // 保存公共配置
    NSMutableDictionary *muCommonDict = [NSMutableDictionary dictionary];
    muCommonDict[@"keychainPasswordField"] = self.keychainPasswordField.stringValue;
    muCommonDict[@"currentUserNameField"] = self.currentUserNameField.stringValue;
    muCommonDict[@"currentPasswordField"] = self.currentPasswordField.stringValue;
    muCommonDict[@"projectLabel"] = self.projectLabel.stringValue;
    muCommonDict[@"exportPathLabel"] = self.exportPathLabel.stringValue;
    [[NSUserDefaults standardUserDefaults] setObject:muCommonDict forKey:@"commonConfig"];
}

#pragma mark - NSTableView委托
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.results.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return self.results[row];
}

#pragma mark - 懒加载
- (NSMutableArray *)results
{
    if (!_results) {
        _results = [NSMutableArray array];
    }
    return _results;
}

@end
