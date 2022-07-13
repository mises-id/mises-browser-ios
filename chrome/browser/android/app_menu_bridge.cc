#include <jni.h>
#include <string>

#include "base/android/build_info.h"
#include "base/android/jni_string.h"
#include "base/strings/string_util.h"
#include "chrome/android/chrome_jni_headers/AppMenuBridge_jni.h"


using base::android::ConvertUTF8ToJavaString;
using base::android::ScopedJavaLocalRef;

static ScopedJavaLocalRef<jstring>;




static void JNI_AppMenuBridge_OpenDevTools(JNIEnv* env, const base::android::JavaParamRef<jobject>&
		    w){};


static void JNI_AppMenuBridge_DisableProxy(JNIEnv* env, const base::android::JavaParamRef<jobject>&
		    p){};

static base::android::ScopedJavaLocalRef<jstring> JNI_AppMenuBridge_GetRunningExtensions(JNIEnv*
		    env, const base::android::JavaParamRef<jobject>& p,
		        const base::android::JavaParamRef<jobject>& w){
  std::string exts;
  return ConvertUTF8ToJavaString(env, exts);
};

static jboolean JNI_AppMenuBridge_IsProxyEnabled(JNIEnv* env, const
		    base::android::JavaParamRef<jobject>& p){return 0;};

static void JNI_AppMenuBridge_GrantExtensionActiveTab(JNIEnv* env, const
		    base::android::JavaParamRef<jobject>& p,
		        const base::android::JavaParamRef<jobject>& w,
			    const base::android::JavaParamRef<jstring>& s){};
