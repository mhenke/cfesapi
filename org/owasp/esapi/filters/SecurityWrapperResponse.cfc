<!---
    /**
    * OWASP Enterprise Security API (ESAPI)
    *
    * This file is part of the Open Web Application Security Project (OWASP)
    * Enterprise Security API (ESAPI) project. For details, please see
    * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
    *
    * Copyright (c) 2011 - The OWASP Foundation
    *
    * The ESAPI is published by OWASP under the BSD license. You should read and accept the
    * LICENSE before you use, modify, and/or redistribute this software.
    *
    * @author Damon Miller
    * @created 2011
    */
    --->
<cfcomponent extends="cfesapi.org.owasp.esapi.lang.Object" implements="cfesapi.org.owasp.esapi.HttpServletResponse" output="false">

	<cfscript>
		instance.ESAPI = "";
		instance.logger = "";
		instance.response = "";

		// modes are "log", "skip", "sanitize", "throw"
		instance.mode = "log";
	</cfscript>

	<cffunction access="public" returntype="SecurityWrapperResponse" name="init" output="false"
	            hint="Construct a safe response that overrides the default response methods with safer versions.">
		<cfargument type="cfesapi.org.owasp.esapi.ESAPI" name="ESAPI" required="true"/>
		<cfargument type="any" name="response" required="true"/>
		<cfargument type="String" name="mode" required="false"/>

		<cfscript>
			instance.ESAPI = arguments.ESAPI;
			instance.logger = instance.ESAPI.getLogger("SecurityWrapperResponse");
			instance.response = arguments.response;

			if(structKeyExists(arguments, "mode")) {
				instance.mode = arguments.mode;
			}

			return this;
		</cfscript>

	</cffunction>

	<cffunction access="package" returntype="any" name="getHttpServletResponse" output="false"
	            hint="javax.servlet.http.HttpServletResponse">

		<cfscript>
			return instance.response;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="addCookie" output="false"
	            hint="Add a cookie to the response after ensuring that there are no encoded or illegal characters in the name and name and value. This method also sets the secure and HttpOnly flags on the cookie. This implementation uses a custom 'set-cookie' header instead of using Java's cookie interface which doesn't allow the use of HttpOnly.">
		<cfargument type="any" name="cookie" required="true" hint="javax.servlet.http.Cookie"/>

		<cfset var local = {}/>

		<cfscript>
			local.name = arguments.cookie.getName();
			local.value = arguments.cookie.getValue();
			local.maxAge = arguments.cookie.getMaxAge();
			local.domain = arguments.cookie.getDomain();
			if(!structKeyExists(local, "domain")) {
				local.domain = "";
			}
			local.path = arguments.cookie.getPath();
			if(!structKeyExists(local, "path")) {
				local.path = "";
			}
			local.secure = arguments.cookie.getSecure();

			// validate the name and value
			local.errors = newComponent("cfesapi.org.owasp.esapi.ValidationErrorList").init();
			local.cookieName = instance.ESAPI.validator().getValidInput(context="cookie name", input=local.name, type="HTTPCookieName", maxLength=50, allowNull=false, errorList=local.errors);
			local.cookieValue = instance.ESAPI.validator().getValidInput(context="cookie value", input=local.value, type="HTTPCookieValue", maxLength=instance.ESAPI.securityConfiguration().getMaxHttpHeaderSize(), allowNull=false, errorList=local.errors);

			// if there are no errors, then just set a cookie header
			if(local.errors.size() == 0) {
				local.header = createCookieHeader(local.name, local.value, local.maxAge, local.domain, local.path, local.secure);
				addHeader("Set-Cookie", local.header);
				return;
			}

			// if there was an error
			if(instance.mode.equals("skip")) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Attempt to add unsafe data to cookie (skip mode). Skipping cookie and continuing.");
				return;
			}

			// add the original cookie to the response and continue
			if(instance.mode.equals("log")) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Attempt to add unsafe data to cookie (log mode). Adding unsafe cookie anyway and continuing.");
				getHttpServletResponse().addCookie(arguments.cookie);
				return;
			}

			// create a sanitized cookie header and continue
			if(instance.mode.equals("sanitize")) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Attempt to add unsafe data to cookie (sanitize mode). Sanitizing cookie and continuing.");
				local.header = createCookieHeader(local.cookieName, local.cookieValue, local.maxAge, local.domain, local.path, local.secure);
				addHeader("Set-Cookie", local.header);
				return;
			}

			// throw an exception if necessary or add original cookie header
			throwError(newComponent("cfesapi.org.owasp.esapi.errors.IntrusionException").init(instance.ESAPI, "Security error", "Attempt to add unsafe data to cookie (throw mode)"));
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="String" name="createCookieHeader" output="false">
		<cfargument type="String" name="name" required="true"/>
		<cfargument type="String" name="value" required="true"/>
		<cfargument type="numeric" name="maxAge" required="true"/>
		<cfargument type="String" name="domain" required="true"/>
		<cfargument type="String" name="path" required="true"/>
		<cfargument type="boolean" name="secure" required="true"/>

		<cfset var local = {}/>

		<cfscript>
			// create the special cookie header instead of creating a Java cookie
			// Set-Cookie:<name>=<value>[; <name>=<value>][; expires=<date>][;
			// domain=<domain_name>][; path=<some_path>][; secure][;HttpOnly]
			local.header = arguments.name & "=" & arguments.value;
			if(arguments.maxAge > -1) {
				local.header &= "; Max-Age=" & arguments.maxAge;
			}
			if(arguments.domain != "") {
				local.header &= "; Domain=" & arguments.domain;
			}
			if(arguments.path != "") {
				local.header &= "; Path=" & arguments.path;
			}
			if(arguments.secure || instance.ESAPI.securityConfiguration().getForceSecureCookies()) {
				local.header &= "; Secure";
			}
			if(instance.ESAPI.securityConfiguration().getForceHttpOnlyCookies()) {
				local.header &= "; HttpOnly";
			}
			return local.header;
		</cfscript>

	</cffunction>

	<!--- addDateHeader --->

	<cffunction access="public" returntype="void" name="addHeader" output="false"
	            hint="Add a header to the response after ensuring that there are no encoded or illegal characters in the name and name and value.">
		<cfargument type="String" name="name" required="true"/>
		<cfargument type="String" name="value" required="true"/>

		<cfset var local = {}/>

		<cfscript>
			try {
				local.strippedName = newJava("org.owasp.esapi.StringUtilities").stripControls(arguments.name);
				local.strippedValue = newJava("org.owasp.esapi.StringUtilities").stripControls(arguments.value);
				local.safeName = instance.ESAPI.validator().getValidInput("addHeader", local.strippedName, "HTTPHeaderName", 20, false);
				local.safeValue = instance.ESAPI.validator().getValidInput("addHeader", local.strippedValue, "HTTPHeaderValue", instance.ESAPI.securityConfiguration().getMaxHttpHeaderSize(), false);
				/*
				 * FIXME
				 * We are using setHeader() here instead of addHeader()
				 * Shouldn't setHeader() overwrite a header of the same name?
				 * It does not appear to be doing that. It is appending headers of the same name.
				 */
				getHttpServletResponse().setHeader(javaCast("string", local.safeName), javaCast("string", local.safeValue));
			}
			catch(cfesapi.org.owasp.esapi.errors.ValidationException e) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Attempt to add invalid header denied", e);
			}
		</cfscript>

	</cffunction>

	<!--- TODO - add the missing method below --->
	<!--- addIntHeader --->
	<!--- containsHeader --->
	<!--- encodeRedirectURL --->
	<!--- encodeURL --->
	<!--- flushBuffer --->
	<!--- getBufferSize --->
	<!--- getCharacterEncoding --->
	<!--- getContentType --->
	<!--- getLocale --->
	<!--- getOutputStream --->
	<!--- getWriter --->
	<!--- isCommitted --->
	<!--- reset --->
	<!--- resetBuffer --->
	<!--- sendError --->
	<!--- sendRedirect --->
	<!--- setBufferSize --->
	<!--- setCharacterEncoding --->
	<!--- setContentLength --->

	<cffunction access="public" returntype="void" name="setContentType" output="false">
		<cfargument type="String" name="type" required="true"/>

		<cfscript>
			getHttpServletResponse().setContentType(arguments.type);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setDateHeader" output="false"
	            hint="Add a date header to the response after ensuring that there are no encoded or illegal characters in the name.">
		<cfargument type="String" name="name" required="true"/>
		<cfargument type="numeric" name="date" required="true"/>

		<cfset var local = {}/>

		<cfscript>
			try {
				local.safeName = instance.ESAPI.validator().getValidInput("safeSetDateHeader", arguments.name, "HTTPHeaderName", 20, false);
				getHttpServletResponse().setDateHeader(local.safeName, arguments.date);
			}
			catch(cfesapi.org.owasp.esapi.errors.ValidationException e) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Attempt to set invalid date header name denied", e);
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setHeader" output="false"
	            hint="Add a header to the response after ensuring that there are no encoded or illegal characters in the name and value.">
		<cfargument type="String" name="name" required="true"/>
		<cfargument type="String" name="value" required="true"/>

		<cfset var local = {}/>

		<cfscript>
			try {
				local.strippedName = newJava("org.owasp.esapi.StringUtilities").stripControls(arguments.name);
				local.strippedValue = newJava("org.owasp.esapi.StringUtilities").stripControls(arguments.value);
				local.safeName = instance.ESAPI.validator().getValidInput("setHeader", local.strippedName, "HTTPHeaderName", 20, false);
				local.safeValue = instance.ESAPI.validator().getValidInput("setHeader", local.strippedValue, "HTTPHeaderValue", instance.ESAPI.securityConfiguration().getMaxHttpHeaderSize(), false);
				getHttpServletResponse().setHeader(local.safeName, local.safeValue);
			}
			catch(cfesapi.org.owasp.esapi.errors.ValidationException e) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Attempt to set invalid header denied", e);
			}
		</cfscript>

	</cffunction>

	<!--- setIntHeader --->
	<!--- setLocale --->
	<!--- setStatus --->
	<!--- getHTTPMessage --->
</cfcomponent>