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
<cfcomponent displayname="UserTest" extends="cfesapi.test.org.owasp.esapi.lang.TestCase" output="false" hint="The Class UserTest.">

	<cfscript>
		instance.ESAPI = newComponent("cfesapi.org.owasp.esapi.ESAPI").init();
	</cfscript>

	<cffunction access="private" returntype="cfesapi.org.owasp.esapi.reference.DefaultUser" name="createTestUser" output="false"
	            hint="Creates the test user.">
		<cfargument required type="String" name="password" hint="the password"/>

		<cfset var local = {}/>

		<cfscript>
			local.username = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.e = newJava("java.lang.Exception").init();
			local.stackTrace = local.e.getStackTrace();
			newJava("java.lang.System").out.println("Creating user " & local.username & " for " & local.stackTrace[1].getMethodName());
			local.user = instance.ESAPI.authenticator().createUser(local.username, arguments.password, arguments.password);
			return local.user;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="setUp" output="false">

		<cfscript>
			structClear(request);
			structClear(session);
			cleanUpUsers();
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="tearDown" output="false">

		<cfscript>
			structClear(request);
			structClear(session);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testAddRole" output="false"
	            hint="Test of testAddRole method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("addRole");
			local.authenticator = instance.ESAPI.authenticator();
			local.accountName = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.password = instance.ESAPI.authenticator().generateStrongPassword();
			local.role = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_LOWERS);
			local.user = local.authenticator.createUser(local.accountName, local.password, local.password);
			local.user.addRole(local.role);
			assertTrue(local.user.isInRole(local.role));
			assertFalse(local.user.isInRole("ridiculous"));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testAddRoles" output="false"
	            hint="Test of addRoles method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("addRoles");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			local.set = [];
			local.set.add("rolea");
			local.set.add("roleb");
			local.user.addRoles(local.set);
			assertTrue(local.user.isInRole("rolea"));
			assertTrue(local.user.isInRole("roleb"));
			assertFalse(local.user.isInRole("ridiculous"));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testChangePassword" output="false"
	            hint="Test of changePassword method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("changePassword");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = "Password12!@";
			local.user = createTestUser(local.oldPassword);
			newJava("java.lang.System").out.println("Hash of " & local.oldPassword & " = " & local.authenticator.getHashedPassword(local.user));
			local.password1 = "SomethingElse34##$";
			local.user.changePassword(local.oldPassword, local.password1, local.password1);
			newJava("java.lang.System").out.println("Hash of " & local.password1 & " = " & local.authenticator.getHashedPassword(local.user));
			assertTrue(local.user.verifyPassword(local.password1));
			local.password2 = "YetAnother56%^";
			local.user.changePassword(local.password1, local.password2, local.password2);
			newJava("java.lang.System").out.println("Hash of " & local.password2 & " = " & local.authenticator.getHashedPassword(local.user));
			try {
				local.user.changePassword(local.password2, local.password1, local.password1);
				fail("Shouldn't be able to reuse a password");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationCredentialsException e) {
				// expected
			}
			assertTrue(local.user.verifyPassword(local.password2));
			assertFalse(local.user.verifyPassword("badpass"));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testDisable" output="false"
	            hint="Test of disable method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("disable");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			local.user.enable();
			assertTrue(local.user.isEnabled());
			local.user.disable();
			assertFalse(local.user.isEnabled());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testEnable" output="false"
	            hint="Test of enable method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("enable");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			local.user.enable();
			assertTrue(local.user.isEnabled());
			local.user.disable();
			assertFalse(local.user.isEnabled());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testFailedLoginLockout" output="false"
	            hint="Test of failedLoginCount lockout, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("failedLoginLockout");
			local.user = createTestUser("failedLoginLockout");
			local.user.enable();
			local.request = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest").init();
			local.response = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse").init();
			instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);

			local.user.loginWithPassword(password="failedLoginLockout");

			try {
				local.user.loginWithPassword(password="ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			newJava("java.lang.System").out.println("FAILED: " & local.user.getFailedLoginCount());
			assertFalse(local.user.isLocked());

			try {
				local.user.loginWithPassword(password="ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			newJava("java.lang.System").out.println("FAILED: " & local.user.getFailedLoginCount());
			assertFalse(local.user.isLocked());

			try {
				local.user.loginWithPassword(password="ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			newJava("java.lang.System").out.println("FAILED: " & local.user.getFailedLoginCount());
			assertTrue(local.user.isLocked());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetAccountName" output="false"
	            hint="Test of getAccountName method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("getAccountName");
			local.user = createTestUser("getAccountName");
			local.accountName = instance.ESAPI.randomizer().getRandomString(7, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.user.setAccountName(local.accountName);
			assertEquals(local.accountName.toLowerCase(), local.user.getAccountName());
			assertFalse("ridiculous" == local.user.getAccountName());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetLastFailedLoginTime" output="false"
	            hint="Test get last failed login time.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("getLastLoginTime");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			try {
				local.user.loginWithPassword(password="ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			local.llt1 = local.user.getLastFailedLoginTime();
			sleep(100);// need a short delay to separate attempts
			try {
				local.user.loginWithPassword(password="ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			local.llt2 = local.user.getLastFailedLoginTime();
			assertTrue(local.llt1.before(local.llt2));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetLastLoginTime" output="false"
	            hint="Test get last login time.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("getLastLoginTime");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			local.user.verifyPassword(local.oldPassword);
			local.llt1 = local.user.getLastLoginTime();
			sleep(10);// need a short delay to separate attempts
			local.user.verifyPassword(local.oldPassword);
			local.llt2 = local.user.getLastLoginTime();
			assertTrue(local.llt1.before(local.llt2));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetLastPasswordChangeTime" output="false"
	            hint="Test getLastPasswordChangeTime method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("getLastPasswordChangeTime");
			local.user = createTestUser("getLastPasswordChangeTime");
			local.t1 = local.user.getLastPasswordChangeTime();
			sleep(10);// need a short delay to separate attempts
			local.newPassword = instance.ESAPI.authenticator().generateStrongPassword(local.user, "getLastPasswordChangeTime");
			local.user.changePassword("getLastPasswordChangeTime", local.newPassword, local.newPassword);
			local.t2 = local.user.getLastPasswordChangeTime();
			assertTrue(local.t2.after(local.t1));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetRoles" output="false"
	            hint="Test of getRoles method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("getRoles");
			local.authenticator = instance.ESAPI.authenticator();
			local.accountName = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.password = instance.ESAPI.authenticator().generateStrongPassword();
			local.role = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_LOWERS);
			local.user = local.authenticator.createUser(local.accountName, local.password, local.password);
			local.user.addRole(local.role);
			local.roles = local.user.getRoles();
			assertTrue(local.roles.size() > 0);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetScreenName" output="false"
	            hint="Test of getScreenName method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("getScreenName");
			local.user = createTestUser("getScreenName");
			local.screenName = instance.ESAPI.randomizer().getRandomString(7, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.user.setScreenName(local.screenName);
			assertEquals(local.screenName, local.user.getScreenName());
			assertFalse("ridiculous" == local.user.getScreenName());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testGetSessions" output="false">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("getSessions");
			local.authenticator = instance.ESAPI.authenticator();
			local.accountName = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.password = instance.ESAPI.authenticator().generateStrongPassword();
			local.user = local.authenticator.createUser(local.accountName, local.password, local.password);
			local.session1 = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpSession").init();
			local.user.addSession(local.session1);
			local.session2 = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpSession").init();
			local.user.addSession(local.session2);
			local.session3 = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpSession").init();
			local.user.addSession(local.session3);
			local.sessions = local.user.getSessions();
			local.i = local.sessions.iterator();
			while(local.i.hasNext()) {
				local.s = local.i.next();
				newJava("java.lang.System").out.println(">>>" & local.s.getId());
			}
			assertTrue(local.sessions.size() == 3);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testAddSession" output="false">

		<cfscript>
			// TODO
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testRemoveSession" output="false">

		<cfscript>
			// TODO
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testIncrementFailedLoginCount" output="false"
	            hint="Test of incrementFailedLoginCount method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("incrementFailedLoginCount");
			local.user = createTestUser("incrementFailedLoginCount");
			local.user.enable();
			assertEquals(0, local.user.getFailedLoginCount());
			local.request = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest").init();
			local.response = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse").init();
			instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);
			try {
				local.user.loginWithPassword(password="ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			assertEquals(1, local.user.getFailedLoginCount());
			try {
				local.user.loginWithPassword(password="ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			assertEquals(2, local.user.getFailedLoginCount());
			try {
				local.user.loginWithPassword(password="ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			assertEquals(3, local.user.getFailedLoginCount());
			try {
				local.user.loginWithPassword(password="ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			assertTrue(local.user.isLocked());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testIsEnabled" output="false"
	            hint="Test of isEnabled method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("isEnabled");
			local.user = createTestUser("isEnabled");
			local.user.disable();
			assertFalse(local.user.isEnabled());
			local.user.enable();
			assertTrue(local.user.isEnabled());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testIsInRole" output="false"
	            hint="Test of isInRole method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("isInRole");
			local.user = createTestUser("isInRole");
			local.role = "TestRole";
			assertFalse(local.user.isInRole(local.role));
			local.user.addRole(local.role);
			assertTrue(local.user.isInRole(local.role));
			assertFalse(local.user.isInRole("Ridiculous"));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testIsLocked" output="false"
	            hint="Test of isLocked method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("isLocked");
			local.user = createTestUser("isLocked");
			local.user.lock();
			assertTrue(local.user.isLocked());
			local.user.unlock();
			assertFalse(local.user.isLocked());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testIsSessionAbsoluteTimeout" output="false"
	            hint="Test of isSessionAbsoluteTimeout method, of class org.owasp.esapi.IntrusionDetector.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("isSessionAbsoluteTimeout");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			local.now = getTickCount();
			// setup request and response
			local.request = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest").init();
			local.response = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse").init();
			instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);
			local.session = local.request.getSession();

			// set session creation -3 hours (default is 2 hour timeout)
			local.session.setCreationTime(local.now - (1000 * 60 * 60 * 3));
			assertTrue(local.user.isSessionAbsoluteTimeout());

			// set session creation -1 hour (default is 2 hour timeout)
			local.session.setCreationTime(local.now - (1000 * 60 * 60 * 1));
			assertFalse(local.user.isSessionAbsoluteTimeout());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testIsSessionTimeout" output="false"
	            hint="Test of isSessionTimeout method, of class org.owasp.esapi.IntrusionDetector.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("isSessionTimeout");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			local.now = getTickCount();
			// setup request and response
			local.request = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest").init();
			local.response = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse").init();
			instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);
			local.session = local.request.getSession();

			// set creation -30 mins (default is 20 min timeout)
			local.session.setAccessedTime(local.now - 1000 * 60 * 30);
			assertTrue(local.user.isSessionTimeout());

			// set creation -1 hour (default is 20 min timeout)
			local.session.setAccessedTime(local.now - 1000 * 60 * 10);
			assertFalse(local.user.isSessionTimeout());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testLock" output="false"
	            hint="Test of lockAccount method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("lock");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			local.user.lock();
			assertTrue(local.user.isLocked());
			local.user.unlock();
			assertFalse(local.user.isLocked());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testLoginWithPassword" output="false"
	            hint="Test of loginWithPassword method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("loginWithPassword");
			local.request = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest").init();
			local.session = local.request.getSession();
			assertFalse(local.session.getInvalidated());
			local.user = createTestUser("loginWithPassword");
			local.user.enable();
			local.user.loginWithPassword(local.request, "loginWithPassword");
			assertTrue(local.user.isLoggedIn());
			local.user.logout();
			assertFalse(local.user.isLoggedIn());
			assertFalse(local.user.isLocked());
			try {
				local.user.loginWithPassword(local.request, "ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			assertFalse(local.user.isLoggedIn());
			try {
				local.user.loginWithPassword(local.request, "ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			try {
				local.user.loginWithPassword(local.request, "ridiculous");
			}
			catch(cfesapi.org.owasp.esapi.errors.AuthenticationLoginException e) {
				// expected
			}
			assertTrue(local.user.isLocked());
			local.user.unlock();
			assertTrue(local.user.getFailedLoginCount() == 0);
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testLogout" output="false"
	            hint="Test of logout method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("logout");
			local.request = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletRequest").init();
			local.response = newComponent("cfesapi.test.org.owasp.esapi.http.MockHttpServletResponse").init();
			local.session = local.request.getSession();
			assertFalse(local.session.getInvalidated());
			local.authenticator = instance.ESAPI.authenticator();
			instance.ESAPI.httpUtilities().setCurrentHTTP(local.request, local.response);
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			local.user.enable();
			newJava("java.lang.System").out.println(local.user.getLastLoginTime());
			local.user.loginWithPassword(password=local.oldPassword);
			assertTrue(local.user.isLoggedIn());
			// get new session after user logs in
			local.session = local.request.getSession();
			assertFalse(local.session.getInvalidated());
			local.user.logout();
			assertFalse(local.user.isLoggedIn());
			assertTrue(local.session.getInvalidated());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testRemoveRole" output="false"
	            hint="Test of testRemoveRole method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("removeRole");
			local.role = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_LOWERS);
			local.user = createTestUser("removeRole");
			local.user.addRole(local.role);
			assertTrue(local.user.isInRole(local.role));
			local.user.removeRole(local.role);
			assertFalse(local.user.isInRole(local.role));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testResetCSRFToken" output="false"
	            hint="Test of testResetCSRFToken method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("resetCSRFToken");
			local.user = createTestUser("resetCSRFToken");
			local.token1 = local.user.resetCSRFToken();
			local.token2 = local.user.resetCSRFToken();
			assertFalse(local.token1.equals(local.token2));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSetAccountName" output="false"
	            hint="Test of setAccountName method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("setAccountName");
			local.user = createTestUser("setAccountName");
			local.accountName = instance.ESAPI.randomizer().getRandomString(7, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.user.setAccountName(local.accountName);
			assertEquals(local.accountName.toLowerCase(), local.user.getAccountName());
			assertFalse("ridiculous" == local.user.getAccountName());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSetExpirationTime" output="false"
	            hint="Test of setExpirationTime method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			local.longAgo = newJava("java.util.Date").init(javaCast("long", 0));
			local.now = newJava("java.util.Date").init();
			assertTrue(local.longAgo.before(local.now), "new Date(0) returned " & local.longAgo & " which is considered before new Date() " & local.now & ". Please report this output to the email list or as a issue");
			local.password = instance.ESAPI.randomizer().getRandomString(8, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.user = createTestUser(local.password);
			local.user.setExpirationTime(local.longAgo);
			assertTrue(local.user.isExpired());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSetRoles" output="false"
	            hint="Test of setRoles method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("setRoles");
			local.user = createTestUser("setRoles");
			local.user.addRole("user");
			assertTrue(local.user.isInRole("user"));
			local.set = [];
			local.set.add("rolea");
			local.set.add("roleb");
			local.user.setRoles(local.set);
			assertFalse(local.user.isInRole("user"));
			assertTrue(local.user.isInRole("rolea"));
			assertTrue(local.user.isInRole("roleb"));
			assertFalse(local.user.isInRole("ridiculous"));
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testSetScreenName" output="false"
	            hint="Test of setScreenName method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("setScreenName");
			local.user = createTestUser("setScreenName");
			local.screenName = instance.ESAPI.randomizer().getRandomString(7, newJava("org.owasp.esapi.reference.DefaultEncoder").CHAR_ALPHANUMERICS);
			local.user.setScreenName(local.screenName);
			assertEquals(local.screenName, local.user.getScreenName());
			assertFalse("ridiculous" == local.user.getScreenName());
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="void" name="testUnlock" output="false"
	            hint="Test of unlockAccount method, of class org.owasp.esapi.User.">
		<cfset var local = {}/>

		<cfscript>
			newJava("java.lang.System").out.println("unlockAccount");
			local.authenticator = instance.ESAPI.authenticator();
			local.oldPassword = local.authenticator.generateStrongPassword();
			local.user = createTestUser(local.oldPassword);
			local.user.lock();
			assertTrue(local.user.isLocked());
			local.user.unlock();
			assertFalse(local.user.isLocked());
		</cfscript>

	</cffunction>

</cfcomponent>