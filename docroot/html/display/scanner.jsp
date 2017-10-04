<%@ include file="/html/init.jsp" %>

<%
String contentType = ParamUtil.getString(request, "content-type", "web-content");

boolean scanLinks = ParamUtil.getBoolean(request, "scan-links", true);
boolean scanImages = ParamUtil.getBoolean(request, "scan-images", false);
boolean useBrowserAgent = ParamUtil.getBoolean(request, "use-browser-agent", true);

boolean linkSuccess = ParamUtil.getBoolean(request, "link-success", true);
boolean linkRedirect = ParamUtil.getBoolean(request, "link-redirect", true);
boolean linkError = ParamUtil.getBoolean(request, "link-error", true);

String back = "javascript:history.go(-1);";

String userAgent = "null";
if (useBrowserAgent)
	userAgent = request.getHeader("User-Agent");

String scanType = LinkScannerConstants.linkImagesLabel(scanLinks, scanImages);

List<ContentLinks> contentLinksList = (new LinkScannerUtil()).getContentLinks(contentType, scopeGroupId, liferayPortletRequest, liferayPortletResponse, themeDisplay, scanLinks, scanImages);

int scanCount = 0;

for (ContentLinks contentLinks : contentLinksList) {
	scanCount = scanCount + contentLinks.getLinksSize();
}

boolean rowAlt = false;
%>

<liferay-ui:header
	backURL="<%= back %>"
	title="<%= contentType %>"
/>

<c:choose>
	<c:when test='<%= !(scanCount > 0) %>'>

		<div class="portlet-msg-info">
			<liferay-ui:message arguments="<%= contentType %>" key="no-links-were-found-for-x" />
		</div>
		
	</c:when>
	<c:otherwise>

<div class="lfr-search-container ">
	<div class="taglib-search-iterator-page-iterator-top">
		<div class="taglib-page-iterator" id="<portlet:namespace/>SearchContainerPageIteratorTop">
			<div class="search-results">Scanning <%= scanCount %> <liferay-ui:message key="<%= scanType %>" /> for <%= contentLinksList.size() %> <liferay-ui:message key="<%= contentType %>" /> items.</div>

			<div id="linkScannerProgressBarContainer">
				<div class="linkScannerProgressBar"></div>
			</div>

			<liferay-ui:panel collapsible="<%= true %>" extended="<%= true %>" id="linkScannerOptions" persistState="<%= true %>" title="options">
				<liferay-ui:message key="result-hover-description" />
				</br>
				<div class="link-scanner-legend-counter">
					<strong>&nbsp;</strong></br>
					<div id="scanCount"><%=scanCount%></div>
					<div id="linkSuccess">0</div>
					<div id="linkRedirect">0</div>
					<div id="linkError">0</div>
				</div>				
				
				<div class="link-scanner-legend-right">
					<strong>Legend</strong>
					<div class="link-scanner-result-legend link-scanner-unchecked"><liferay-ui:message key="link-unchecked" /></div>
					<div class="link-scanner-result-legend link-scanner-success"><liferay-ui:message key="link-success" /></div>
					<div class="link-scanner-result-legend link-scanner-redirect"><liferay-ui:message key="link-redirect" /></div>
					<div class="link-scanner-result-legend link-scanner-error"><liferay-ui:message key="link-error" /></div>
					
				</div>
			</liferay-ui:panel>
		</div>
	</div>

	<div id="<portlet:namespace/>SearchContainer" class="yui3-widget aui-component aui-searchcontainer">
		<div class="results-grid aui-searchcontainer-content searchcontainer-content" id="<portlet:namespace/>SearchContainerSearchContainer">
			<table class="table table-bordered table-hover table-striped taglib-search-iterator" data-searchcontainerid="<portlet:namespace/>SearchContainer">
				<thead class="table-columns">
					<tr class="portlet-section-header results-header">
						<th class="col-1 first table-first-header" id="<portlet:namespace/>SearchContainer_col-result" width="1%">
							<span class="result-column-name">Result</span>
						</th>
						<th class="col-2 last table-last-header" id="<portlet:namespace/>SearchContainer_col-title-link">
							<span class="result-column-name">Title / Link</span>
						</th>
					</tr>
				</thead>
				<tbody class="table-data">

<%
	for (ContentLinks contentLinks : contentLinksList) {

		//rowAlt = !rowAlt;

		for (String link : contentLinks.getLinks()) {

			//rowAlt = !rowAlt;
			String linkShort = (link.length() > 150 ? link.substring(0, 150) + "..." : link);

			if (link.startsWith("//")) {
				try {
					link = themeDisplay.getURLPortal().substring(0, themeDisplay.getURLPortal().indexOf("//")) + link;
				}
				catch (Exception e) {
					
				}
			}
%>
					<tr class="link-scanner-row-link results-row <%= (rowAlt?"portlet-section-alternate alt":"portlet-section-body") %>">
						<td class="table-cell align-left col-1 first valign-middle" colspan="1" headers="<portlet:namespace/>SearchContainer_col-result">
							<div class="link-scanner-result link-scanner-unchecked" title="" data-link="<%= link %>" data-isportal="<%= new LinkScannerUtil().isPortalLink(link, themeDisplay) %>"></div>
						</td>
						<td class="table-cell align-left col-2 last valign-middle" colspan="1" headers="<portlet:namespace/>SearchContainer_col-title-link">
		
						
						<%
								if (contentType.equals("rss-portlet-subscriptions") || 
									permissionChecker.hasPermission(
									scopeGroupId, contentLinks.getClassName(),
									contentLinks.getClassPK(), "UPDATE")) {
						
									String editUrl = contentType.equals("rss-portlet-subscriptions") ? contentLinks.getContentEditLink() : 
										"javascript:Liferay.Util.openWindow({id: '" + renderResponse.getNamespace() + "editAsset', " + 
										"title: '" + LanguageUtil.format(pageContext, "edit-x", HtmlUtil.escape(contentLinks.getContentTitle())) + "', " + 
										"uri:'" + HtmlUtil.escapeURL(contentLinks.getContentEditLink()) + "'});";
						%>
													<liferay-ui:icon
														image="edit"
														label="<%= true %>"
														message="<%= contentLinks.getContentTitle() %>"
														target='<%= contentType.equals("rss-portlet-subscriptions") ? "_blank" : null %>'
														url="<%= editUrl %>"
													/>
						<%
								}
								else {
						%>
													<%= HtmlUtil.escape(contentLinks.getContentTitle()) %>
						<%
								}
						%>						
						
							</br>
							<a href="<%= link %>" target="_blank" class="link-scanner-link"><%= HtmlUtil.escape(linkShort) %></a>
						</td>
					</tr>
<%
		}
	}
%>
				</tbody>
			</table>
		</div>
	</div>
</div>

<aui:script>
	Liferay.provide(
		window,
		'<portlet:namespace />scanLinks',
		function() {
			var A = AUI();

			var links = A.all('.link-scanner-result');

			links.each(function (node) {
				if (node.attr('data-isportal') == 'true') {
					A.io.request(
						node.attr('data-link'),
						{
							on: {
								failure: function(event, id, obj) {
									pbIncrement();
									node.removeClass('link-scanner-unchecked');
									node.removeClass('link-scanner-success');
									node.addClass('link-scanner-error');
									node.attr('title','AJAX Failed');

									linkErrorCount++;
									document.getElementById('linkError').innerHTML = linkErrorCount;
									scanCount--;
									document.getElementById('scanCount').innerHTML = scanCount;
									<% if (!linkError) {%>
										node.ancestor('tr').setStyle('display', 'none');
									<% } %>									
								},
								success: function(event, id, obj) {
									pbIncrement();
									node.removeClass('link-scanner-unchecked');
									node.removeClass('link-scanner-error');
									node.addClass('link-scanner-success');
									node.attr('title','AJAX Success');

									linkSuccessCount++;
									document.getElementById('linkSuccess').innerHTML = linkSuccessCount;
									scanCount--;
									document.getElementById('scanCount').innerHTML = scanCount;
									<% if (!linkSuccess) {%>
										node.ancestor('tr').setStyle('display', 'none');
									<% } %>												
								}
							}
						}
					);
				} else {
					encodelink=encodeURIComponent(node.attr('data-link'));
					A.io.request(
						'/api/jsonws/link-scanner-portlet.linkscannerurlstatus/get-response?p_auth=' + Liferay.authToken + '&url=' + encodelink + '&userAgent=' + userAgent,
						{
							dataType: 'json',
							on: {
								failure: function(event, id, obj) {
									pbIncrement();
									node.removeClass('link-scanner-unchecked');
									node.removeClass('link-scanner-success');
									node.addClass('link-scanner-error');
									node.attr('title','Web Service Request Failed');
									
									linkErrorCount++;
									document.getElementById('linkError').innerHTML = linkErrorCount;
									scanCount--;
									document.getElementById('scanCount').innerHTML = scanCount;
									<% if (!linkError) {%>
										node.ancestor('tr').setStyle('display', 'none');
									<% } %>									
								},
								success: function(event, id, obj) {
									pbIncrement();
									var response = this.get('responseData');
									var exception = response.exception;
									
									if (!exception) {
										if (response[0] >= 100 && response[0] < 300) {
											node.removeClass('link-scanner-unchecked');
											node.removeClass('link-scanner-error');
											node.removeClass('link-scanner-redirect');
											node.addClass('link-scanner-success');
	
											linkSuccessCount++;
											document.getElementById('linkSuccess').innerHTML = linkSuccessCount;
											scanCount--;
											document.getElementById('scanCount').innerHTML = scanCount;
											<% if (!linkSuccess) {%>
												node.ancestor('tr').setStyle('display', 'none');
											<% } %>												
										} else if (response[0] >= 300 && response[0] < 400) {
											node.removeClass('link-scanner-unchecked');
											node.removeClass('link-scanner-error');
											node.removeClass('link-scanner-success');
											node.addClass('link-scanner-redirect');
											
											linkRedirectCount++;
											document.getElementById('linkRedirect').innerHTML = linkRedirectCount;
											scanCount--;
											document.getElementById('scanCount').innerHTML = scanCount;
											<% if (!linkRedirect) {%>
												node.ancestor('tr').setStyle('display', 'none');
											<% } %>													
										} else {
											node.removeClass('link-scanner-unchecked');
											node.removeClass('link-scanner-success');
											node.removeClass('link-scanner-redirect');
											node.addClass('link-scanner-error');
											
											linkErrorCount++;							
											document.getElementById('linkError').innerHTML = linkErrorCount;
											scanCount--;
											document.getElementById('scanCount').innerHTML = scanCount;
											<% if (!linkError) {%>
												node.ancestor('tr').setStyle('display', 'none');
											<% } %>
										}
										node.attr('title','WS: ' + response[0] + ' - ' + response[1]);
									} else {
										node.removeClass('link-scanner-unchecked');
										node.removeClass('link-scanner-success');
										node.removeClass('link-scanner-redirect');
										node.addClass('link-scanner-error');
										node.attr('title','WS: ' + exception);
										
										linkErrorCount++;			
										document.getElementById('linkError').innerHTML = linkErrorCount;
										scanCount--;
										document.getElementById('scanCount').innerHTML = scanCount;
										<% if (!linkError) {%>
											node.ancestor('tr').setStyle('display', 'none');
										<% } %>
									}
								}
							}
						}
					);
				}
			});
		},
		['aui-io']
	);

	var progressBarTotal = <%= scanCount %>;
	var progressBarCount = 0;
	var progressBarPercent = 0;
	var progressBar
	var userAgent = '<%= HtmlUtil.escapeJS(userAgent) %>';
	
	var linkErrorCount = 0;
	var linkRedirectCount = 0;
	var linkSuccessCount = 0;
	var scanCount = <%= scanCount %>;
	
	function pbIncrement() {
		++progressBarCount;
		progressBarPercent = (progressBarCount / progressBarTotal) * 100;
		progressBar.set('label', 'Scanning... ' + Math.round(progressBarPercent) + '%');
		progressBar.set('value', Math.round(progressBarPercent));
	}
	
	AUI().ready('aui-tooltip', 
		'aui-io-plugin',
		'aui-progressbar',
		function(A) {
			
			new A.TooltipDelegate(
				{
					trigger: '.link-scanner-result',
				}
			);
			
			progressBar = new A.ProgressBar(
				{
					boundingBox: '#linkScannerProgressBarContainer',
					contentBox: '.linkScannerProgressBar',
					label: 'Scanning...',
					on: {
						complete: function(e) {
							this.set('label', 'Complete! 100%');
						}
					},
					value: progressBarCount
				}
			).render();
	<portlet:namespace />scanLinks();
		}
	);
</aui:script>

	</c:otherwise>
</c:choose>
