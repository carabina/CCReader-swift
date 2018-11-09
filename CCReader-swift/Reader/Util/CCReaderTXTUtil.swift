//
//  CCReaderTXTUtil.swift
//  CCReader-swift
//
//  Created by zhouen on 2018/10/31.
//  Copyright © 2018年 zhouen. All rights reserved.
//

import Foundation
import UIKit

struct CCReaderTXTUtil {

    
    static func catalogue(text:String) -> [CCCatalogueProtocol]? {
        
        if (text.count == 0) {
            return nil;
        }
        let regex = "第(.{1,})(章|节|集|卷|部|篇).*(\r|\n)"
        
        let catalog = self.catalogue(regex: regex, from: text)
        
        return catalog
    }
    
    
    
    
    /// 获取章节目录
    ///
    /// - Parameters:
    ///   - regex: 正则表达式
    private static func catalogue(regex: String, from text: String) -> [CCCatalogueProtocol]? {
        var list = [CCCatalogueProtocol]()
        
        let range = NSRange(location: 0, length: text.count)
        let reg = try! NSRegularExpression(pattern: regex, options: .caseInsensitive)
        let array = reg.matches(in: text, options: .reportProgress, range: range)
        
        
        var index = 0
        for TextCheckingResult in array {
            let item = CCCatalogue()
            let matchRange = TextCheckingResult.range
            let text = (text as NSString).substring(with: matchRange)
            
            //最前面的简介处理
            if matchRange.location > 0 && index == 0{
                let jitem = CCCatalogue()
                jitem.cid = 0
                jitem.title = "简介"
                jitem.position = 0
                list.append(jitem)
                
                index += 1
            }
            
            item.cid = index
            item.title = text
            item.position = matchRange.location
            
            list.append(item)
            
            index += 1
        }
        return list
    
    }
    
    static func content(by catalogue: [CCCatalogueProtocol], at index: Int , from text: String) -> String? {
        if index == catalogue.count - 1 {
            var item = catalogue[index]
            let content = (text as NSString).substring(from: item.position)
            item.content = content
            return content
        }
        
        if index < catalogue.count {
            var item1 = catalogue[index]
            let item2 = catalogue[index + 1]
            
            let content = (text as NSString).substring(with: NSRange(location: item1.position, length: item2.position - item1.position))
            item1.content = content
            return content
        }
        
        return nil
    }
    
    /*

    NSMutableArray *array = [NSMutableArray array];
    if (regex == nil && [text isEqualToString:@""])
    {
    return nil;
    }
    
    NSRange range = { 0 , text.length };
    NSInteger location = 0;
    NSInteger length = 0;
    
    while (true) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    range = [text rangeOfString:regex options:NSRegularExpressionSearch range:range];
    if (range.location == NSNotFound && range.length == 0)
    {
    break;
    }
    [dict setObject:@(range.location) forKey:@"position"];
    
    //获取每一章节的标题
    NSString *chapterTitle = [text substringWithRange:range];
    chapterTitle = [chapterTitle stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    [dict setObject:chapterTitle forKey:@"title"];
    
    [array addObject:dict];
    
    location = range.location + range.length;
    length = text.length - range.location - range.length;
    range = NSMakeRange(location, length);
    }
    
    //开头序言的处理
    if (array.count > 0) {
    NSDictionary *dict = array[0];
    NSInteger positon = [dict[@"position"] integerValue];
    if (positon > 0) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"开篇" forKey:@"title"];
    [dict setObject:@(0) forKey:@"position"];
    [array insertObject:dict atIndex:0];
    }
    }
    
    return array;
    }

 */
    
    
    static func paging(text: String, by size: CGSize) -> [NSAttributedString]? {
        if text.count == 0 {
            return nil
        }
        
        let font = UIFont(name: "Heiti SC", size: 20)
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        /// 行间距
        paragraphStyle.lineSpacing = 9.0
        /// 段落间距
        paragraphStyle.paragraphSpacing = 0
    
        
        let label = UILabel()
        label.text = "中国"
        label.font = font
        label.sizeToFit()
        
        paragraphStyle.firstLineHeadIndent = label.frame.size.width
        
        
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : font!,
            NSAttributedString.Key.foregroundColor : UIColor.black,
            
            //字符间距
            NSAttributedString.Key.kern : 0,
            NSAttributedString.Key.paragraphStyle : paragraphStyle
            ]
        let attrString = NSAttributedString(string: text, attributes: attrs)
    
        return self.coreTextPaging(attrString: attrString, size: size)
    }
    
    static func coreTextPaging(attrString: NSAttributedString, size: CGSize) -> [NSAttributedString] {
        
        var pagingResult = [NSAttributedString]()
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)

        let width = Double(size.width)
        let height = Double(size.height)
        let rect =  CGRect(x: 0, y: 0, width: width, height: height)
        
        
        let path = CGPath(rect: rect, transform: nil)

        var textPos = 0;
        let strLength = attrString.length
        while (textPos < strLength)  {
            //设置路径
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, nil);
            //生成frame
            let frameRange = CTFrameGetVisibleStringRange(frame);
            let ra = NSMakeRange(frameRange.location, frameRange.length);
            
            //获取范围并转换为NSRange，然后以NSAttributedString形式保存
            let str = attrString.attributedSubstring(from: ra)
            pagingResult.append(str)
 
            //移动当前文本位置
            textPos += frameRange.length;
            
//            CFRelease(frame);
        }
//        CGPathRelease(path);
//        CFRelease(framesetter);
        return pagingResult;
    
    }

}

