<%@ include file="/html/init.jsp" %>

<%
String originalUrl = ParamUtil.getString(request, "original_url", "/agenda");
String newUrl = ParamUtil.getString(request, "new_url", "/agenda-new");

String back = "javascript:history.go(-1);";
String headerTitle = "TEST";

List<ContentLinks> contentLinksList = new ArrayList<ContentLinks>();
contentLinksList = new LinkScannerUtil().searchAndReplaceLinksInWebContent(scopeGroupId, liferayPortletRequest, liferayPortletResponse, themeDisplay, originalUrl, newUrl, "", "");
%>

<liferay-ui:header
	backURL="<%= back %>"
	title="<%= headerTitle %>"
/>

