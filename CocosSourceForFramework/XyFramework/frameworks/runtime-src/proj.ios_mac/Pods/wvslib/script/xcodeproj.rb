#!/usr/bin/env ruby

require 'xcodeproj'
@p = ""
@project_name = `ls | grep .xcodeproj`.strip
@cnt = 0
while @project_name == "" or @project_name =="Pods.xcodeproj" or @project_name =="_Pods.xcodeproj" do
    @p = "../" + @p
    @project_name = `ls #{@p} | grep .xcodeproj`.strip
    @cnt = @cnt + 1
    if @cnt >= 3 then
        break
    end
end 
if @project_name == "" or @project_name =="Pods.xcodeproj" or @project_name =="_Pods.xcodeproj" then
    puts "Sorry, Not Found xcodeproj!"
    return
end

project = Xcodeproj::Project.open(@p + @project_name)
def changeCfg (config, attr)
    if config.build_settings[attr].is_a? String then
        config.build_settings[attr] = [config.build_settings[attr]]
    end
    if config.build_settings[attr] and not config.build_settings[attr].include? "$(inherited)" then
        config.build_settings[attr] << "$(inherited)"
        puts "[" + config.name + "] auto add \"$(inherited)\":" + attr
    end
end
project.targets.each do |target|
    target.build_configurations.each do |config|
        changeCfg(config, "OTHER_LDFLAGS")
        changeCfg(config, "LIBRARY_SEARCH_PATHS")
        changeCfg(config, "HEADER_SEARCH_PATHS")
        @INFOPLIST = config.build_settings["INFOPLIST_FILE"]
        `/usr/libexec/PlistBuddy -c "Delete :NSAppTransportSecurity" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Delete :CFBundleURLTypes" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string TencentWeibo" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string sinaweibo" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string zhihu" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string momochat" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string youku" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string renren" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string weixin" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string wechat" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string baidumusic" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string tudou" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string mqq" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string QQmusic" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string gifshow" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string alipay" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string Twitter" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string instagram" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string tg" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string bilibili" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string weico" "#{@INFOPLIST}"`
        `/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes: string ntesopen" "#{@INFOPLIST}"`
    end
end
project.save