<%@ include file="/html/init.jsp" %>

<%

String contentType = ParamUtil.getString(request, "content-type", "web-content");
String originalUrl = ParamUtil.getString(request, "original_url", themeDisplay.getURLPortal());
String newUrl = ParamUtil.getString(request, "new_url", themeDisplay.getURLPortal());
boolean scanLinks = ParamUtil.getBoolean(request, "only_scan_links", true);
String webContent = "web-content";

%>

<p><b><liferay-ui:message key="view-header-text" /></b></p>
<br/>

<liferay-portlet:renderURL varImpl="extractLinksURL">
	<portlet:param name="mvcPath" value='<%= templatePath + "scanner.jsp" %>' />
</liferay-portlet:renderURL>

<aui:form action="<%= extractLinksURL %>" method="get" name="fm">
	<liferay-portlet:renderURLParams varImpl="extractLinksURL" />
	<aui:input name="content-type" type="hidden" value="<%= webContent %>" />
	<aui:fieldset>
		<%--
		<aui:field-wrapper name="content-types" label="content-types">
			<aui:select name="content-type" inlineLabel="right" label="">
				<aui:option label="web-content" selected="<%= contentType.equals(webContent) %>" />
			</aui:select>
		</aui:field-wrapper>	
		 --%>
		 
		<aui:input name="original_url" required="true" value="<%=originalUrl%>" style="width:50%;" >
			<aui:validator name="url"/>
		</aui:input>

		<aui:input name="new_url" required="false" value="<%=newUrl%>" style="width:50%;" >
			<aui:validator name="url"/>
		</aui:input>
		
		<aui:input inlineLabel="right" name="only_scan_links" type="checkbox" checked="<%=scanLinks%>" />
		
		<aui:button-row>
			<aui:button onClick='<%= renderResponse.getNamespace() + "extractLinks();" %>' value="process" />
		</aui:button-row>

	</aui:fieldset>
</aui:form>

<aui:script>
	function <portlet:namespace />extractLinks() {
		var server_url = "<%=themeDisplay.getURLPortal()%>";
		var original_url = (<portlet:namespace />original_url.value);
		var new_url = (<portlet:namespace />new_url.value);
		var only_scan_links = (<portlet:namespace />only_scan_links.value);
		
		if (only_scan_links == "true"){
			if (original_url != server_url &&
				original_url != server_url+"/"	
				) {
				submitForm(document.<portlet:namespace />fm);
			} else {
				alert("<liferay-ui:message key="please-complete-original-url" />");
			}
		} else {
			if (original_url != server_url && 
				original_url != server_url+"/" && 
				new_url != server_url && 
				new_url != server_url+"/" && 
				original_url != new_url ){
				submitForm(document.<portlet:namespace />fm);
			} else if (new_url == ""){
				alert("<liferay-ui:message key="please-complete-new-url" />");
			} else {
				alert("<liferay-ui:message key="please-complete-different-urls" />");
			}
		}
		
	}
</aui:script>