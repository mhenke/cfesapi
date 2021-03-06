<!--- /**
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
 */ --->
<cfcomponent displayname="AbstractAuthenticator" extends="cfesapi.org.owasp.esapi.lang.Object" output="false" hint="A partial implementation of the Authenticator interface. This class should not implement any methods that would be meant to modify a User object, since that's probably implementation specific. DO NOT implement Authenticator here due to CF's weird implementation of interfaces! Implement Authenticator on component that extends this one.">

	<cfscript>
		instance.ESAPI = "";

		/**
		 * Key for user in session
		 */
		this.USER = "ESAPIUserSessionKey";

		instance.logger = "";

		/**
		 * The currentUser ThreadLocal variable is used to make the currentUser available to any call in any part of an
		 * application. Otherwise, each thread would have to pass the User object through the calltree to any methods that
		 * need it. Because we want exceptions and log calls to contain user data, that could be almost anywhere. Therefore,
		 * the ThreadLocal approach simplifies things greatly. <P> As a possible extension, one could create a delegation
		 * framework by adding another ThreadLocal to hold the delegating user identity.
		 */
		instance.currentUser = "";
	</cfscript>

	<cffunction access="public" returntype="AbstractAuthenticator" name="init" output="false">
		<cfargument required="true" type="cfesapi.org.owasp.esapi.ESAPI" name="ESAPI"/>

		<cfscript>
			super.init();
			instance.ESAPI = arguments.ESAPI;
			instance.logger = instance.ESAPI.getLogger("Authenticator");
			instance.currentUser = newComponent("cfesapi.org.owasp.esapi.reference.AbstractAuthenticator$ThreadLocalUser").init(instance.ESAPI);
			return this;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="clearCurrent" output="false">

		<cfscript>
			// instance.logger.logWarning(newJava("org.owasp.esapi.Logger").SECURITY, "************Clearing threadlocals. Thread" & Thread.currentThread().getName() );
			instance.currentUser.remove();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="boolean" name="exists" output="false">
		<cfargument required="true" type="String" name="accountName"/>

		<cfscript>
			return isObject(getUserByAccountName(arguments.accountName));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="cfesapi.org.owasp.esapi.User" name="getCurrentUser" output="false"
	            hint="Returns the currently logged user as set by the setCurrentUser() methods. Must not log in this method because the logger calls getCurrentUser() and this could cause a loop.">
		<cfset var local = {}/>

		<cfscript>
			local.user = instance.currentUser.get();
			if(!structKeyExists(local, "user") || !isObject(local.user)) {
				local.user = newComponent("cfesapi.org.owasp.esapi.User$ANONYMOUS").init(instance.ESAPI);
			}
			return local.user;
		</cfscript>

	</cffunction>

	<cffunction access="public" name="getUserFromSession" output="false" hint="Gets the user from session.">
		<cfargument type="cfesapi.org.owasp.esapi.HttpServletRequest" name="request" default="#instance.ESAPI.currentRequest()#"/>

		<cfset var local = {}/>

		<cfscript>
			local.session = arguments.request.getSession(false);
			if(!structKeyExists(local, "session") || !isObject(local.session)) {
				return "";
			}
			return instance.ESAPI.httpUtilities().getSessionAttribute(key=this.USER);
		</cfscript>

	</cffunction>

	<cffunction access="private" name="getUserFromRememberToken" output="false" hint="Returns the user if a matching remember token is found, or null if the token is missing, token is corrupt, token is expired, account name does not match and existing account, or hashed password does not match user's hashed password.">
		<cfargument type="cfesapi.org.owasp.esapi.HttpServletRequest" name="request" default="#instance.ESAPI.currentRequest()#"/>
		<cfargument type="cfesapi.org.owasp.esapi.HttpServletResponse" name="response" default="#instance.ESAPI.currentResponse()#"/>

		<cfset var local = {}/>

		<cfscript>
			try {
				local.token = instance.ESAPI.httpUtilities().getCookie(arguments.request, instance.ESAPI.httpUtilities().REMEMBER_TOKEN_COOKIE_NAME);
				if(local.token == "") {
					return "";
				}

				// TODO - kww - URLDecode token first, and THEN unseal. See Google Issue 144.
				local.data = instance.ESAPI.encryptor().unseal(local.token).split("\|");
				if(arrayLen(local.data) != 2) {
					instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Found corrupt or expired remember token");
					instance.ESAPI.httpUtilities().killCookie(arguments.request, arguments.response, instance.ESAPI.httpUtilities().REMEMBER_TOKEN_COOKIE_NAME);
					return "";
				}

				local.username = local.data[1];
				local.password = local.data[2];
				local.user = getUserByAccountName(local.username);
				if(!isObject(local.user)) {
					instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Found valid remember token but no user matching " & local.username);
					return "";
				}

				instance.logger.info(newJava("org.owasp.esapi.Logger").SECURITY_SUCCESS, "Logging in user with remember token: " & local.user.getAccountName());
				local.user.loginWithPassword(arguments.request, local.password);
				return local.user;
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationException ae) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Login via remember me cookie failed", ae);
			}
			catch(cfesapi.org.owasp.esapi.errors.EncryptionException e) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_FAILURE, "Remember token was missing, corrupt, or expired");
			}
			instance.ESAPI.httpUtilities().killCookie(arguments.request, arguments.response, instance.ESAPI.httpUtilities().REMEMBER_TOKEN_COOKIE_NAME);
			return "";
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="cfesapi.org.owasp.esapi.User" name="loginWithUsernameAndPassword" output="false"
	            hint="Utility method to extract credentials and verify them.">
		<cfargument required="true" type="cfesapi.org.owasp.esapi.HttpServletRequest" name="request" hint="The current HTTP request"/>

		<cfset var local = {}/>

		<cfscript>

			local.username = arguments.request.getParameter(instance.ESAPI.securityConfiguration().getUsernameParameterName());
			local.password = arguments.request.getParameter(instance.ESAPI.securityConfiguration().getPasswordParameterName());

			// if a logged-in user is requesting to login, log them out first
			local.user = getCurrentUser();
			if(isObject(local.user) && !local.user.isAnonymous()) {
				instance.logger.warning(newJava("org.owasp.esapi.Logger").SECURITY_SUCCESS, "User requested relogin. Performing logout then authentication");
				local.user.logout();
			}

			// now authenticate with username and password
			if(local.username == "" || local.password == "") {
				if(local.username == "") {
					local.username = "unspecified user";
				}
				local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationCredentialsException").init(instance.ESAPI, "Authentication failed", "Authentication failed for " & local.username & " because of blank username or password");
				throwError(local.exception);
			}
			local.user = getUserByAccountName(local.username);
			if(!isObject(local.user)) {
				local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationCredentialsException").init(instance.ESAPI, "Authentication failed", "Authentication failed because user " & local.username & " doesn't exist");
				throwError(local.exception);
			}
			local.user.loginWithPassword(arguments.request, local.password);

			arguments.request.setAttribute(local.user.getCSRFToken(), "authenticated");
			return local.user;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="cfesapi.org.owasp.esapi.User" name="login" output="false">
		<cfargument type="cfesapi.org.owasp.esapi.HttpServletRequest" name="request" default="#instance.ESAPI.currentRequest()#"/>
		<cfargument type="cfesapi.org.owasp.esapi.HttpServletResponse" name="response" default="#instance.ESAPI.currentResponse()#"/>

		<cfset var local = {}/>

		<cfscript>

			if(!isObject(arguments.request) || !isObject(arguments.response)) {
				local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationCredentialsException").init(instance.ESAPI, "Invalid request", "Request or response objects were blank");
				throwError(local.exception);
			}

			// if there's a user in the session then use that
			local.user = getUserFromSession(arguments.request);

			// else if there's a remember token then use that
			if(!structKeyExists(local, "user") || !isInstanceOf(local.user, "cfesapi.org.owasp.esapi.User")) {
				local.user = getUserFromRememberToken(arguments.request, arguments.response);
			}

			// else try to verify credentials - throws exception if login fails
			if(!structKeyExists(local, "user") || !isInstanceOf(local.user, "cfesapi.org.owasp.esapi.reference.DefaultUser")) {
				local.user = loginWithUsernameAndPassword(arguments.request);

				// warn if this authentication request was not POST or non-SSL connection, exposing credentials or session id
				try {
					instance.ESAPI.httpUtilities().assertSecureRequest(arguments.request);
				}
				catch(cfesapi.org.owasp.esapi.errors.AccessControlException e) {
					local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationException").init(instance.ESAPI, "Attempt to login with an insecure request", e.detail, e);
					throwError(local.exception);
				}
			}

			// if we have a user, verify we are on SSL (POST not required)
			else {

				// warn if this authentication request was non-SSL connection, exposing session id
				try {
					instance.ESAPI.httpUtilities().assertSecureChannel(arguments.request);
				}
				catch(cfesapi.org.owasp.esapi.errors.AccessControlException e) {
					local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationException").init(instance.ESAPI, "Attempt to access secure content with an insecure request", e.detail, e);
					throwError(local.exception);
				}
			}

			// set last host address
			local.user.setLastHostAddress(arguments.request.getRemoteAddr());

			// don't let anonymous user log in
			if(local.user.isAnonymous()) {
				local.user.logout();
				local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationLoginException").init(instance.ESAPI, "Login failed", "Anonymous user cannot be set to current user. User: " & local.user.getAccountName());
				throwError(local.exception);
			}

			// don't let disabled users log in
			if(!local.user.isEnabled()) {
				local.user.logout();
				local.user.incrementFailedLoginCount();
				local.user.setLastFailedLoginTime(newJava("java.util.Date").init());
				local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationLoginException").init(instance.ESAPI, "Login failed", "Disabled user cannot be set to current user. User: " & local.user.getAccountName());
				throwError(local.exception);
			}

			// don't let locked users log in
			if(local.user.isLocked()) {
				local.user.logout();
				local.user.incrementFailedLoginCount();
				local.user.setLastFailedLoginTime(newJava("java.util.Date").init());
				local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationLoginException").init(instance.ESAPI, "Login failed", "Locked user cannot be set to current user. User: " & local.user.getAccountName());
				throwError(local.exception);
			}

			// don't let expired users log in
			if(local.user.isExpired()) {
				local.user.logout();
				local.user.incrementFailedLoginCount();
				local.user.setLastFailedLoginTime(newJava("java.util.Date").init());
				local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationLoginException").init("Login failed", "Expired user cannot be set to current user. User: " & local.user.getAccountName());
				throwError(local.exception);
			}

			// check session inactivity timeout
			if(local.user.isSessionTimeout(arguments.request)) {
				local.user.logout();
				local.user.incrementFailedLoginCount();
				local.user.setLastFailedLoginTime(newJava("java.util.Date").init());
				local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationLoginException").init(instance.ESAPI, "Login failed", "Session inactivity timeout: " & local.user.getAccountName());
				throwError(local.exception);
			}

			// check session absolute timeout
			if(local.user.isSessionAbsoluteTimeout(arguments.request)) {
				local.user.logout();
				local.user.incrementFailedLoginCount();
				local.user.setLastFailedLoginTime(newJava("java.util.Date").init());
				local.exception = newComponent("cfesapi.org.owasp.esapi.errors.AuthenticationLoginException").init(instance.ESAPI, "Login failed", "Session absolute timeout: " & local.user.getAccountName());
				throwError(local.exception);
			}

			//set Locale to the user object in the session from request
			local.user.setLocaleESAPI(arguments.request.getLocaleESAPI());

			// create new session for this User
			local.session = arguments.request.getSession();
			local.user.addSession(local.session);
			local.session.setAttribute(this.USER, local.user);

			setCurrentUser(local.user);
			return local.user;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="logout" output="false">
		<cfset var local = {}/>

		<cfscript>
			local.user = getCurrentUser();
			if(isObject(local.user) && !local.user.isAnonymous()) {
				local.user.logout();
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setCurrentUser" output="false">
		<cfargument required="true" type="cfesapi.org.owasp.esapi.User" name="user"/>

		<cfscript>
			instance.currentUser.setUser(arguments.user);
		</cfscript>

	</cffunction>

</cfcomponent>