/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package edu.nps.portlet.linkscanner.service.impl;

import java.net.HttpURLConnection;
import java.net.URL;
import java.net.UnknownHostException;
import java.nio.charset.StandardCharsets;

import javax.xml.bind.DatatypeConverter;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.Validator;

import edu.nps.portlet.linkscanner.service.base.LinkScannerURLStatusLocalServiceBaseImpl;
import edu.nps.portlet.linkscanner.util.LinkScannerConstants;

/**
 * The implementation of the link scanner u r l status local service.
 *
 * <p>
 * All custom service methods should be put in this class. Whenever methods are added, rerun ServiceBuilder to copy their definitions into the {@link edu.nps.portlet.linkscanner.service.LinkScannerURLStatusLocalService} interface.
 *
 * <p>
 * This is a local service. Methods of this service will not have security checks based on the propagated JAAS credentials because this service can only be accessed from within the same VM.
 * </p>
 *
 * @author Craig Vershaw
 * @see edu.nps.portlet.linkscanner.service.base.LinkScannerURLStatusLocalServiceBaseImpl
 * @see edu.nps.portlet.linkscanner.service.LinkScannerURLStatusLocalServiceUtil
 */
public class LinkScannerURLStatusLocalServiceImpl
	extends LinkScannerURLStatusLocalServiceBaseImpl {
	/*
	 * NOTE FOR DEVELOPERS:
	 *
	 * Never reference this interface directly. Always use {@link edu.nps.portlet.linkscanner.service.LinkScannerURLStatusLocalServiceUtil} to access the link scanner u r l status local service.
	 */

	public String[] getResponse(String url)
					throws PortalException, SystemException {

		return getResponse(url, null, 0);
	}

	public String[] getResponse(String url, String userAgent)
				throws PortalException, SystemException {
	
		return getResponse(url, userAgent, 0);
	}
	
	public String[] getResponseOLD(String url, String userAgent)
		throws PortalException, SystemException {

		String[] result = new String[3];
		result[0] = "-1";
		result[1] = "Unknown Error";
		result[2] = "";

		try {

			URL urlObject = new URL(url);
			
			HttpURLConnection.setFollowRedirects(true);
			HttpURLConnection httpURLConnection = (HttpURLConnection) urlObject.openConnection();
			httpURLConnection.setRequestMethod("HEAD");
			
			if (Validator.isNotNull(userAgent))
				httpURLConnection.setRequestProperty("User-Agent", userAgent);
			
			result[0] = String.valueOf(httpURLConnection.getResponseCode());
			result[1] = httpURLConnection.getResponseMessage();
			result[2] = httpURLConnection.getContentType();
			
			if (httpURLConnection.getResponseCode() == HttpURLConnection.HTTP_BAD_METHOD) {
				
				_log.debug("HTTP 405 Bad Method. Trying with GET: " + url);
				
				HttpURLConnection httpURLConnectionGet = (HttpURLConnection) urlObject.openConnection();
				httpURLConnectionGet.setRequestMethod("GET");
				httpURLConnectionGet.setUseCaches(false);
				
				if (Validator.isNotNull(userAgent))
					httpURLConnectionGet.setRequestProperty("User-Agent", userAgent);
				
				result[0] = String.valueOf(httpURLConnectionGet.getResponseCode());
				result[1] = httpURLConnectionGet.getResponseMessage();
				result[2] = httpURLConnectionGet.getContentType();
			}
		}
		catch(UnknownHostException unknownHostException){

			_log.error("Unknown Host: " + url);
			result[1] = "Unknown Host";
		}
		catch (Exception e) {

			_log.error("Error: " + url);
			_log.error(e.getMessage());
			result[1] = e.getMessage();
		}

		return result;
	}

	public String[] getResponse(String URLName, String userAgent, int redirectionTryLimit)
			throws PortalException, SystemException {
		
			String[] result = new String[3];
			result[0] = "-1";
			result[1] = "Unknown Error";
			result[2] = "";

			if (redirectionTryLimit == LinkScannerConstants.REDIRECTION_TRY_LIMIT) {
				result[1] = "Redirection is reaching limit. - URL : " + URLName ;			
				_log.error(result[1]);
					
				return result;
			}
			
			HttpURLConnection conn = null;
			HttpURLConnection.setFollowRedirects(true);
			
			try {

				////_log.info("Checking URL: " + URLName);
				
				// Check if URL string is valid
				if (!Validator.isUrl(URLName)) {
					result[1] = "NOT a valid URL. - URL : " + URLName;			
  					_log.error(result[1]);
  					
  					return result;
				}
				
				// Check if the URL is broken
				URL url = new URL(URLName);
				conn = (HttpURLConnection) url.openConnection();
				conn.setRequestMethod("GET");
				
				if (Validator.isNotNull(userAgent)) {
					conn.setRequestProperty("User-Agent",
							"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0");
				}
				
				if (LinkScannerConstants.IS_APACHE_AUTH_PROPERTY_EXISTS) {
					conn.setRequestProperty("Authorization", "Basic " + 
							DatatypeConverter.printBase64Binary(LinkScannerConstants.APACHE_AUTH_LOGIN.getBytes(StandardCharsets.UTF_8)));
				}		
				
				conn.connect();
				
				////_log.info("Response code: " + conn.getResponseCode() + ". Message: " + conn.getResponseMessage());

				String redirLink = conn.getHeaderField("Location");
				if (redirLink != null && !url.toExternalForm().equals(redirLink)) {
					////_log.info("Redirection link: " + redirLink);
					redirectionTryLimit++;
					result = getResponse(redirLink, userAgent, redirectionTryLimit);
				} else {

					result[0] = String.valueOf(conn.getResponseCode());
					result[1] = conn.getResponseMessage();
					result[2] = conn.getContentType();
					
					if (conn.getResponseCode() == HttpURLConnection.HTTP_BAD_METHOD) {
						
						result[1] = "HTTP 405 Bad Method. - URL : " + URLName ;	
	  					_log.error(result[1]);
	  					
	  					if (conn != null) {
	  						conn.disconnect();
	  					}
	  					
	  					return result;
	
					}
				}
			}
			catch(UnknownHostException unknownHostException){
				result[1] = "UnknownHostExceptiont. " + unknownHostException.getMessage() + " - URL : " + URLName;	
				_log.error(result[1]);
			}
			catch (Exception e) {
				result[1] = "Exception. " + e.getMessage() + " - URL : " + URLName;
				_log.error(result[1]);
			} finally {
				if (conn != null) {
					conn.disconnect();
				}
			}
			
			////_log.info("OK Checking URL: " + URLName);
			
			return result;
		}	
	
	public String getResponseCode(String url)
		throws PortalException, SystemException {

		return getResponse(url)[0];
	}

	public String getResponseCode(String url, String userAgent)
		throws PortalException, SystemException {

		return getResponse(url, userAgent)[0];
	}

	public String getResponseString(String url)
		throws PortalException, SystemException {

		String[] result = getResponse(url);
		
		return result[0] + " " + result[1];
	}

	public String getResponseString(String url, String userAgent)
		throws PortalException, SystemException {

		String[] result = getResponse(url, userAgent);
		
		return result[0] + " " + result[1];
	}

	private static Log _log = LogFactoryUtil.getLog(LinkScannerURLStatusLocalServiceImpl.class);
}
