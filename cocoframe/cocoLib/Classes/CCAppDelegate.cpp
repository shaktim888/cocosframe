#include "CCAppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"
#include "ide-support/CCSimpleConfigParser.h"
#include "ZipLoader.h"

#if (CC_TARGET_PLATFORM != CC_PLATFORM_LINUX)
#include "ide-support/CodeIDESupport.h"
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
#include "runtime/Runtime.h"
#include "ide-support/RuntimeLuaImpl.h"
#endif

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

CCAppDelegate::CCAppDelegate()
{
}

CCAppDelegate::~CCAppDelegate()
{
    SimpleAudioEngine::end();

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif

}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void CCAppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

// If you want to use packages manager to install more packages,
// don't modify or remove this function
static int register_all_packages()
{
    return 0; //flag for packages manager
}

bool CCAppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

    register_all_packages();

    //register custom function
    //LuaStack* stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    auto runtimeEngine = RuntimeEngine::getInstance();
    runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
    runtimeEngine->start();
#else
    if (CCSimpleConfigParser::getInstance()->isPack()) {
        std::string output = std::string(getBundleWritableRoot()) + "qwert1/";
        std::string path = std::string(getBundleResRoot()) + CCSimpleConfigParser::getInstance()->getPackSrc();
        if(!isBundleDirectoryExist(output.c_str())) {
            loadZipFile(path.c_str(), output.c_str());
        }
        cocos2d::FileUtils::getInstance()->addSearchPath(output);
        cocos2d::FileUtils::getInstance()->addSearchPath(output + "src/");
        cocos2d::FileUtils::getInstance()->addSearchPath(output + "res/");
        cocos2d::FileUtils::getInstance()->addSearchPath(output + "src/res/");
        if (engine->executeScriptFile((output + "src/main.lua").c_str()))
        {
            return false;
        }
    }else{
        if (engine->executeScriptFile("src/main.lua"))
        {
            return false;
        }
    }
    
#endif

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void CCAppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void CCAppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
