package org.chromium.chrome.browser;

import org.chromium.base.annotations.NativeMethods;
import org.chromium.content_public.browser.WebContents;
import org.chromium.chrome.browser.profiles.Profile;

public class AppMenuBridge {
	@NativeMethods
	interface Natives {
		void openDevTools(WebContents w);
		void disableProxy(Profile p);
		String getRunningExtensions(Profile p,WebContents w);
		boolean isProxyEnabled(Profile p);
		void grantExtensionActiveTab(Profile p,WebContents w,String s);
		void callExtension(Profile p,WebContents w,String s);
	}

}
