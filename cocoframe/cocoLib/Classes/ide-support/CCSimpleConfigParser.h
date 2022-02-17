#ifndef __SIMPLE_CONFIG_PARSER_H__
#define __SIMPLE_CONFIG_PARSER_H__

#include <string>
#include <vector>
#include "cocos2d.h"
#include "json/document.h"
using namespace std;
USING_NS_CC;

#define CONFIG_FILE "config.json"

class CCSimpleConfigParser
{
public:
    static CCSimpleConfigParser *getInstance(void);
    static void purge();

    void readConfig(const string &filepath = "");
    bool isLanscape();
    bool isPack();
    const std::string& getPackSrc();
    rapidjson::Document& getConfigJsonRoot();
private:
    CCSimpleConfigParser(void);
    static CCSimpleConfigParser *s_sharedSimpleConfigParserInstance;
    bool _isLandscape;
    std::string _packSrc;
    
    rapidjson::Document _docRootjson;
};

#endif  // __SIMPLE_CONFIG_PARSER_H__

