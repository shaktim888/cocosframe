
#include "json/document.h"
#include "json/filestream.h"
#include "json/stringbuffer.h"
#include "json/writer.h"
#include "CCSimpleConfigParser.h"

// SimpleConfigParser
CCSimpleConfigParser *CCSimpleConfigParser::s_sharedSimpleConfigParserInstance = NULL;
CCSimpleConfigParser *CCSimpleConfigParser::getInstance(void)
{
    if (!s_sharedSimpleConfigParserInstance)
    {
        s_sharedSimpleConfigParserInstance = new CCSimpleConfigParser();
        s_sharedSimpleConfigParserInstance->readConfig();
    }
    return s_sharedSimpleConfigParserInstance;
}

void CCSimpleConfigParser::purge()
{
    CC_SAFE_DELETE(s_sharedSimpleConfigParserInstance);
}

void CCSimpleConfigParser::readConfig(const string &filepath)
{
    string fullPathFile = filepath;
    
    // read config file
    if (fullPathFile.empty())
    {
        fullPathFile = FileUtils::getInstance()->fullPathForFilename(CONFIG_FILE);
    }
    string fileContent = FileUtils::getInstance()->getStringFromFile(fullPathFile);

    if(fileContent.empty())
    {
        CCLOG("config.json is empty!");
        return;
    }
    
    if (_docRootjson.Parse<0>(fileContent.c_str()).HasParseError()) {
        cocos2d::log("read json file %s failed because of %d", fullPathFile.c_str(), _docRootjson.GetParseError());
        return;
    }
    
    if (_docRootjson.HasMember("init_cfg"))
    {
        if(_docRootjson["init_cfg"].IsObject())
        {
            const rapidjson::Value& objectInitView = _docRootjson["init_cfg"];
            if (objectInitView.HasMember("isLandscape") && objectInitView["isLandscape"].IsBool())
            {
                _isLandscape = objectInitView["isLandscape"].GetBool();
            }
            if (objectInitView.HasMember("packSrc") && objectInitView["packSrc"].IsString())
            {
                _packSrc = objectInitView["packSrc"].GetString();
            }
        }
    }
}

CCSimpleConfigParser::CCSimpleConfigParser(void) :
_isLandscape(true), _packSrc("")
{
}

rapidjson::Document& CCSimpleConfigParser::getConfigJsonRoot()
{
    return _docRootjson;
}

bool CCSimpleConfigParser::isLanscape()
{
    return _isLandscape;
}

bool CCSimpleConfigParser::isPack()
{
    return _packSrc != "";
}

const std::string& CCSimpleConfigParser::getPackSrc()
{
    return _packSrc;
}
