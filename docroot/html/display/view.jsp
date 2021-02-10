<%@ include file="/html/init.jsp" %>

<p>
	Select the content type to process for links.</p>

<liferay-portlet:renderURL varImpl="extractLinksURL">
	<portlet:param name="mvcPath" value='<%= templatePath + "scanner.jsp" %>' />
</liferay-portlet:renderURL>

<aui:form action="<%= extractLinksURL %>" method="get" name="fm">
	<liferay-portlet:renderURLParams varImpl="extractLinksURL" />
	<aui:input name="redirect" type="hidden" value="<%= redirect %>" />
	<aui:fieldset>

		<aui:field-wrapper name="content-types" label="content-types">
			<aui:select name="content-type" inlineLabel="right" label="">
				<aui:option label="blog-entries" />
				<aui:option label="bookmarks" />
				<aui:option label="calendar-events" />
				<aui:option label="message-board-messages" />
				<aui:option label="rss-portlet-subscriptions" />
				<aui:option label="web-content" selected="<%= true %>" />
				<aui:option label="wiki-pages" />
			</aui:select>

			<aui:input inlineLabel="right" name="scan-links" type="checkbox" checked="<%= true %>" />
			<aui:input inlineLabel="right" name="scan-images" type="checkbox" />
		</aui:field-wrapper>

		<aui:field-wrapper label="show">
			<div class="link-scanner-result-legend link-scanner-success" style="display:none;">
				<aui:input inlineLabel="right" name="link-success" type="checkbox" checked="<%= false %>" />
			</div>
			<div class="link-scanner-result-legend link-scanner-redirect" style="display:none;">
				<aui:input inlineLabel="right" name="link-redirect" type="checkbox" checked="<%= false %>" />
			</div>
			<div class="link-scanner-result-legend link-scanner-error" style="padding-left:0px;">
				<aui:input inlineLabel="left" name="link-error" type="checkbox" style="display:none; " checked="<%= true %>" />
			</div>
		</aui:field-wrapper>

		<aui:field-wrapper label="options">
			<aui:input inlineLabel="right" name="use-browser-agent" type="checkbox" checked="<%= true %>" helpMessage="use-browser-agent-help" />
		</aui:field-wrapper>

		<aui:button-row>
			<aui:button onClick='<%= renderResponse.getNamespace() + "extractLinks();" %>' value="list" />
		</aui:button-row>

	</aui:fieldset>
</aui:form>

<aui:script>
	function <portlet:namespace />extractLinks() {
		submitForm(document.<portlet:namespace />fm);
	}
</aui:script>

<script>
	var isFirefox = navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
	if(!isFirefox){
		alert("<liferay-ui:message key="please-use-firefox-for-this-plugin" />");
	}
</script>