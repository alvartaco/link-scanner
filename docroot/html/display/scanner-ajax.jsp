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
			
			<%
				String textAreaText = "";
				for (ContentLinks contentLinks : contentLinksList) {
					for (String link : contentLinks.getLinks()) {
						String linkOri = link;
						if (link.startsWith("/")) {
							try {
								link = themeDisplay.getURLPortal() + link;
							}
							catch (Exception e) {
							}
						}
						String editUrl = "";
						String editUrlUri = "";
						String editUrlUriNotScaped = "";
						if (contentType.equals("rss-portlet-subscriptions") || 
							permissionChecker.hasPermission(
							scopeGroupId, contentLinks.getClassName(),
							contentLinks.getClassPK(), "UPDATE")) {
							editUrlUriNotScaped = contentLinks.getContentEditLink();
							
							textAreaText = textAreaText + link + "," + HtmlUtil.escape(contentLinks.getContentTitle()) + "," + editUrlUriNotScaped + "\n";
						
						}
					}
				}
			%>						
			
			<textarea rows="5" cols="200" name="csv" id="textarea" style="display: none;"><%=textAreaText%></textarea>
			
			<div id="textareatable" style="display: none;"></div>
			
			<liferay-ui:panel collapsible="<%= true %>" extended="<%= true %>" id="linkScannerOptions" persistState="<%= true %>" title="options">
				<liferay-ui:message key="result-hover-description" />
				</br>
				<div class="link-scanner-legend-counter">
					<strong>&nbsp;</strong></br>
					<div id="scanCount"><%=scanCount%></div>
					<div id="linkSuccess" style="display:none;" >0</div>
					<div id="linkRedirect" style="display:none;" >0</div>
					<div id="linkError">0</div>
				</div>				
				
				<div class="link-scanner-legend-right">
					<strong>Legend</strong>
					<div class="link-scanner-result-legend link-scanner-unchecked"><liferay-ui:message key="link-unchecked" /></div>
					<div class="link-scanner-result-legend link-scanner-success" style="display:none;" ><liferay-ui:message key="link-success" /></div>
					<div class="link-scanner-result-legend link-scanner-redirect" style="display:none;" ><liferay-ui:message key="link-redirect" /></div>
					<div class="link-scanner-result-legend link-scanner-error"><liferay-ui:message key="link-error" /></div>
					
				</div>
			</liferay-ui:panel>
			
			<button type="button" id="process" onclick="<portlet:namespace />scanLinks();" disabled="true"><liferay-ui:message key="process" /></button>			
			<button type="button" id="convert" onclick="convert();" disabled="true"><liferay-ui:message key="export-to-CSV" /></button>
			
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

		for (String link : contentLinks.getLinks()) {

			String linkOri = link;

			if (link.startsWith("/")) {
				try {
					link = themeDisplay.getURLPortal() + link;
				}
				catch (Exception e) {
					
				}
			}

			String editUrl = "";
			String editUrlUri = "";
			String editUrlUriNotScaped = "";
			
			if (contentType.equals("rss-portlet-subscriptions") || 
				permissionChecker.hasPermission(
				scopeGroupId, contentLinks.getClassName(),
				contentLinks.getClassPK(), "UPDATE")) {
	
				editUrlUriNotScaped = contentLinks.getContentEditLink();
				editUrlUri = HtmlUtil.escapeURL(editUrlUriNotScaped);
				
				editUrl = contentType.equals("rss-portlet-subscriptions") ? contentLinks.getContentEditLink() : 
					"javascript:Liferay.Util.openWindow({id: '" + renderResponse.getNamespace() + "editAsset', " + 
					"title: '" + LanguageUtil.format(pageContext, "edit-x", HtmlUtil.escape(contentLinks.getContentTitle())) + "', " + 
					"uri:'" + editUrlUri + "'});";
			}
			%>
					<tr class="link-scanner-row-link results-row <%= (rowAlt?"portlet-section-alternate alt":"portlet-section-body") %>">
						<td class="table-cell align-left col-1 first valign-middle" colspan="1" headers="<portlet:namespace/>SearchContainer_col-result">
							<div class="link-scanner-result link-scanner-unchecked" title="" data-edit-url-uri-not-scaped="<%= editUrlUriNotScaped %>" data-edit-url="<%= editUrl %>" data-link="<%= link %>" data-isportal="<%= new LinkScannerUtil().isPortalLink(link, themeDisplay) %>"></div>
						</td>
						<td class="table-cell align-left col-2 last valign-middle" colspan="1" headers="<portlet:namespace/>SearchContainer_col-title-link">
		
						
						<%
								if (contentType.equals("rss-portlet-subscriptions") || 
									permissionChecker.hasPermission(
									scopeGroupId, contentLinks.getClassName(),
									contentLinks.getClassPK(), "UPDATE")) {
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
							<a href="<%= link %>" target="_blank" class="link-scanner-link"><%= HtmlUtil.escape(linkOri.length() > 150 ? linkOri.substring(0, 150) + "..." : linkOri) %></a>
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

<script>

function convert() {
    var tbl = "<table class='table table-responsive table-bordered table-striped'><tbody>"
    var lines = document.getElementById("textarea").value.split("\n");
    for (var i = 0; i < lines.length; i++) {
      tbl = tbl + "<tr>"
      var items = lines[i].split(",");
      for (var j = 0; j < items.length; j++) {
        tbl = tbl + "<td>" + items[j] + "</td>";
      }
      tbl = tbl + "</tr>";
    }
    tbl = tbl + "</tbody></table>";
    var divTable = document.getElementById('textareatable');
    divTable.innerHTML = tbl;
    
    export_table_to_csv("table.csv");
  }

function download_csv(csv, filename) {
    var csvFile;
    var downloadLink;

    // CSV FILE
    csvFile = new Blob([csv], {type: "text/csv"});

    // Download link
    downloadLink = document.createElement("a");

    // File name
    downloadLink.download = filename;

    // We have to create a link to the file
    downloadLink.href = window.URL.createObjectURL(csvFile);

    // Make sure that the link is not displayed
    downloadLink.style.display = "none";

    // Add the link to your DOM
    document.body.appendChild(downloadLink);

    // Lanzamos
    downloadLink.click();
}

function export_table_to_csv( filename) {
	var csv = [];
	var rows = document.getElementById('textareatable').querySelectorAll("table tr")
	
    for (var i = 0; i < rows.length; i++) {
		var row = [], cols = rows[i].querySelectorAll("td, th");
		
        for (var j = 0; j < cols.length; j++) 
            row.push(cols[j].innerText);
        
		csv.push(row.join(","));		
	}

    // Download CSV
    download_csv(csv.join("\n"), filename);
}



</script>

<aui:script>


	Liferay.provide(
		window,
		'<portlet:namespace />scanLinks',
		function() {
			var A = AUI();
			
			var links = A.all('.link-scanner-result');
			
			document.getElementById('textarea').value='';
			document.getElementById('textareatable').value='';
			document.getElementById("process").disabled=true;
			document.getElementById("convert").disabled=true;	
			
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
									document.getElementById('textarea').value=document.getElementById('textarea').value + 'AJAX Failed' + ',' + node.attr('data-link') + ',' + node.attr('data-edit-url-uri-not-scaped') + '\n';
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
					var rnd = Math.random();
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
									document.getElementById('textarea').value=document.getElementById('textarea').value + 'AJAX Failed' + ',' + node.attr('data-link') + ',' + node.attr('data-edit-url-uri-not-scaped') + '\n';
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
											if (response[0] == -1) {
												
												node.removeClass('link-scanner-unchecked');
												node.removeClass('link-scanner-success');
												node.removeClass('link-scanner-redirect');
												node.addClass('link-scanner-error');
												
												linkErrorCount++;							
												document.getElementById('linkError').innerHTML = linkErrorCount;
												scanCount--;
												document.getElementById('scanCount').innerHTML = scanCount;
												document.getElementById('textarea').value=document.getElementById('textarea').value + 'ERROR WS: ' + response[0] + ' - ' + response[1] + ',' + node.attr('data-link') + ',' + node.attr('data-edit-url-uri-not-scaped') + '\n';
											} else {
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
											}
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
										document.getElementById('textarea').value=document.getElementById('textarea').value + 'EXCEPTION WS: ' + exception + ',' + node.attr('data-link') + ',' + node.attr('data-edit-url-uri-not-scaped') + '\n';
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
		if (Math.round(progressBarPercent)>90){
			document.getElementById("convert").disabled=false;
		}
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
			document.getElementById("process").disabled=false;
			document.getElementById("convert").disabled=false;
		}
	);
</aui:script>

	</c:otherwise>
</c:choose>
