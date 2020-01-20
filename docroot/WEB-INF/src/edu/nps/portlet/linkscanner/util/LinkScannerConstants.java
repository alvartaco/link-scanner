package edu.nps.portlet.linkscanner.util;

import org.apache.commons.lang3.StringUtils;

import com.liferay.portal.kernel.util.PropsUtil;


public class LinkScannerConstants {

	public static final String LABEL_LINKS = "links";

	public static final String LABEL_IMAGES = "images";

	public static final String LABEL_LINKS_AND_IMAGES = "links-and-images";

	public static String linkImagesLabel(boolean checkLinks, boolean checkImages) {

		if (checkLinks && checkImages) {
			return LABEL_LINKS_AND_IMAGES;
		}
		else if (checkImages) {
			return LABEL_IMAGES;
		}
		else {
			return LABEL_LINKS;
		}
	}

	public static final String LINK_SCANNER_DISPLAY = "linkscanner_WAR_linkscannerportlet";

	public static final String CALENDAR = "1_WAR_calendarportlet";

	// Portal-ext.properties key
	public static final String APACHE_AUTH_USERNAME_KEY = "rioolnet62.nonprod.apache.auth.username";
	public static final String APACHE_AUTH_PASSWORD_KEY = "rioolnet62.nonprod.apache.auth.password";
	// Portal-ext.properties value
	public static final String APACHE_AUTH_USERNAME_VALUE = PropsUtil.get(APACHE_AUTH_USERNAME_KEY);
	public static final String APACHE_AUTH_PASSWORD_VALUE = PropsUtil.get(APACHE_AUTH_PASSWORD_KEY);
	public static final boolean IS_APACHE_AUTH_PROPERTY_EXISTS = StringUtils.isNotBlank(APACHE_AUTH_USERNAME_VALUE)
			&& StringUtils.isNotBlank(APACHE_AUTH_PASSWORD_VALUE);
	public static final String APACHE_AUTH_LOGIN = APACHE_AUTH_USERNAME_VALUE + ":" + APACHE_AUTH_PASSWORD_VALUE;
		
	public static final int REDIRECTION_TRY_LIMIT = 3;
}
