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
/**
 * The User interface represents an application user or user account. There is quite a lot of information that an
 * application must store for each user in order to enforce security properly. There are also many rules that govern
 * authentication and identity management.
 * <P>
 * A user account can be in one of several states. When first created, a User should be disabled, not expired, and
 * unlocked. To start using the account, an administrator should enable the account. The account can be locked for a
 * number of reasons, most commonly because they have failed login for too many times. Finally, the account can expire
 * after the expiration date has been reached. The User must be enabled, not expired, and unlocked in order to pass
 * authentication.
 * 
 * @author <a href="mailto:jeff.williams@aspectsecurity.com?subject=ESAPI question">Jeff Williams</a> at <a href="http://www.aspectsecurity.com">Aspect Security</a>
 * @author Chris Schmidt (chrisisbeef .at. gmail.com) <a href="http://www.digital-ritual.com">Digital Ritual Software</a>
 * @since June 1, 2007
 */
interface extends="cfesapi.org.owasp.esapi.lang.Principal" {

	/**
	 * @return the locale
	 */
	
	public function getLocale();
	
	/**
	 * @param locale the locale to set
	 */
	
	public void function setLocale(required locale);
	
	/**
	 * Adds a role to this user's account.
	 * 
	 * @param role 
	 *         the role to add
	 * 
	 * @throws AuthenticationException 
	 *         the authentication exception
	 */
	
	public void function addRole(required String role);
	
	/**
	 * Adds a set of roles to this user's account.
	 * 
	 * @param newRoles 
	 *         the new roles to add
	 * 
	 * @throws AuthenticationException 
	 *         the authentication exception
	 */
	
	public void function addRoles(required Array newRoles);
	
	/**
	 * Sets the user's password, performing a verification of the user's old password, the equality of the two new
	 * passwords, and the strength of the new password.
	 * 
	 * @param oldPassword 
	 *         the old password
	 * @param newPassword1 
	 *         the new password
	 * @param newPassword2 
	 *         the new password - used to verify that the new password was typed correctly
	 * 
	 * @throws AuthenticationException 
	 *         if newPassword1 does not match newPassword2, if oldPassword does not match the stored old password, or if the new password does not meet complexity requirements 
	 * @throws EncryptionException 
	 */
	
	public void function changePassword(required String oldPassword, 
	                             required String newPassword1,
	                             required String newPassword2);
	
	/**
	 * Disable this user's account.
	 */
	
	public void function disable();
	
	/**
	 * Enable this user's account.
	 */
	
	public void function enable();
	
	/**
	 * Gets this user's account id number.
	 * 
	 * @return the account id
	 */
	
	public numeric function getAccountId();
	
	/**
	 * Gets this user's account name.
	 * 
	 * @return the account name
	 */
	
	public String function getAccountName();
	
	/**
	 * Gets the CSRF token for this user's current sessions.
	 * 
	 * @return the CSRF token
	 */
	
	public String function getCSRFToken();
	
	/**
	 * Returns the date that this user's account will expire.
	 *
	 * @return Date representing the account expiration time.
	 */
	
	public function getExpirationTime();
	
	/**
	 * Returns the number of failed login attempts since the last successful login for an account. This method is
	 * intended to be used as a part of the account lockout feature, to help protect against brute force attacks.
	 * However, the implementor should be aware that lockouts can be used to prevent access to an application by a
	 * legitimate user, and should consider the risk of denial of service.
	 * 
	 * @return the number of failed login attempts since the last successful login
	 */
	
	public numeric function getFailedLoginCount();
	
	/**
	 * Returns the last host address used by the user. This will be used in any log messages generated by the processing
	 * of this request.
	 * 
	 * @return the last host address used by the user
	 */
	
	public String function getLastHostAddress();
	
	/**
	 * Returns the date of the last failed login time for a user. This date should be used in a message to users after a
	 * successful login, to notify them of potential attack activity on their account.
	 * 
	 * @return date of the last failed login
	 * 
	 * @throws AuthenticationException 
	 *         the authentication exception
	 */
	
	public function getLastFailedLoginTime();
	
	/**
	 * Returns the date of the last successful login time for a user. This date should be used in a message to users
	 * after a successful login, to notify them of potential attack activity on their account.
	 * 
	 * @return date of the last successful login
	 */
	
	public function getLastLoginTime();
	
	/**
	 * Gets the date of user's last password change.
	 * 
	 * @return the date of last password change
	 */
	
	public function getLastPasswordChangeTime();
	
	/**
	 * Gets the roles assigned to a particular account.
	 * 
	 * @return an immutable set of roles
	 */
	
	public Array function getRoles();
	
	/**
	 * Gets the screen name (alias) for the current user.
	 * 
	 * @return the screen name
	 */
	
	public String function getScreenName();
	
	/**
	 * Adds a session for this User.
	 * 
	 * @param s
	 *             The session to associate with this user.
	 */
	
	public void function addSession(required s);
	
	/**
	 * Removes a session for this User.
	 * 
	 * @param s
	 *             The session to remove from being associated with this user.
	 */
	
	public void function removeSession(required s);
	
	/**
	 * Returns the list of sessions associated with this User.
	 * @return
	 */
	
	public Array function getSessions();
	
	/**
	 * Increment failed login count.
	 */
	
	public void function incrementFailedLoginCount();
	
	/**
	 * Checks if user is anonymous.
	 * 
	 * @return true, if user is anonymous
	 */
	
	public boolean function isAnonymous();
	
	/**
	 * Checks if this user's account is currently enabled.
	 * 
	 * @return true, if account is enabled 
	 */
	
	public boolean function isEnabled();
	
	/**
	 * Checks if this user's account is expired.
	 * 
	 * @return true, if account is expired
	 */
	
	public boolean function isExpired();
	
	/**
	 * Checks if this user's account is assigned a particular role.
	 * 
	 * @param role 
	 *         the role for which to check
	 * 
	 * @return true, if role has been assigned to user
	 */
	
	public boolean function isInRole(required String role);
	
	/**
	 * Checks if this user's account is locked.
	 * 
	 * @return true, if account is locked
	 */
	
	public boolean function isLocked();
	
	/**
	 * Tests to see if the user is currently logged in.
	 * 
	 * @return true, if the user is logged in
	 */
	
	public boolean function isLoggedIn();
	
	/**
	 * Tests to see if this user's session has exceeded the absolute time out based 
	  * on ESAPI's configuration settings.
	 * 
	 * @return true, if user's session has exceeded the absolute time out
	 */
	
	public boolean function isSessionAbsoluteTimeout();
	
	/**
	  * Tests to see if the user's session has timed out from inactivity based 
	  * on ESAPI's configuration settings.
	  * 
	  * A session may timeout prior to ESAPI's configuration setting due to 
	  * the servlet container setting for session-timeout in web.xml. The 
	  * following is an example of a web.xml session-timeout set for one hour.     
	  *
	  * <session-config>
	  *   <session-timeout>60</session-timeout> 
	  * </session-config>
	  * 
	  * @return true, if user's session has timed out from inactivity based 
	  *               on ESAPI configuration
	  */
	
	public boolean function isSessionTimeout();
	
	/**
	 * Lock this user's account.
	 */
	
	public void function lock();
	
	/**
	 * Login with password.
	 * 
	 * @param password 
	 *         the password
	 * @throws AuthenticationException 
	 *         if login fails
	 */
	
	public void function loginWithPassword(required String password);
	
	/**
	 * Logout this user.
	 */
	
	public void function logout();
	
	/**
	 * Removes a role from this user's account.
	 * 
	 * @param role 
	 *         the role to remove
	 * @throws AuthenticationException 
	 *         the authentication exception
	 */
	
	public void function removeRole(required String role);
	
	/**
	 * Returns a token to be used as a prevention against CSRF attacks. This token should be added to all links and
	 * forms. The application should verify that all requests contain the token, or they may have been generated by a
	 * CSRF attack. It is generally best to perform the check in a centralized location, either a filter or controller.
	 * See the verifyCSRFToken method.
	 * 
	 * @return the new CSRF token
	 * 
	 * @throws AuthenticationException 
	 *         the authentication exception
	 */
	
	public String function resetCSRFToken();
	
	/**
	 * Sets this user's account name.
	 * 
	 * @param accountName the new account name
	 */
	
	public void function setAccountName(required String accountName);
	
	/**
	 * Sets the date and time when this user's account will expire.
	 * 
	 * @param expirationTime the new expiration time
	 */
	
	public void function setExpirationTime(required Date expirationTime);
	
	/**
	 * Sets the roles for this account.
	 * 
	 * @param roles 
	 *         the new roles
	 * 
	 * @throws AuthenticationException 
	 *         the authentication exception
	 */
	
	public void function setRoles(required Array roles);
	
	/**
	 * Sets the screen name (username alias) for this user.
	 * 
	 * @param screenName the new screen name
	 */
	
	public void function setScreenName(required String screenName);
	
	/**
	 * Unlock this user's account.
	 */
	
	public void function unlock();
	
	/**
	 * Verify that the supplied password matches the password for this user. This method
	 * is typically used for "reauthentication" for the most sensitive functions, such
	 * as transactions, changing email address, and changing other account information.
	 * 
	 * @param password 
	 *         the password that the user entered
	 * 
	 * @return true, if the password passed in matches the account's password
	 * 
	 * @throws EncryptionException 
	 */
	
	public boolean function verifyPassword(required String password);
	
	/**
	 * Set the time of the last failed login for this user.
	 * 
	 * @param lastFailedLoginTime the date and time when the user just failed to login correctly.
	 */
	
	public void function setLastFailedLoginTime(required Date lastFailedLoginTime);
	
	/**
	 * Set the last remote host address used by this user.
	 * 
	 * @param remoteHost The address of the user's current source host.
	 */
	
	public void function setLastHostAddress(required String remoteHost);
	
	/**
	 * Set the time of the last successful login for this user.
	 * 
	 * @param lastLoginTime the date and time when the user just successfully logged in.
	 */
	
	public void function setLastLoginTime(required Date lastLoginTime);
	
	/**
	 * Set the time of the last password change for this user.
	 * 
	 * @param lastPasswordChangeTime the date and time when the user just successfully changed his/her password.
	 */
	
	public void function setLastPasswordChangeTime(required Date lastPasswordChangeTime);
	
	/**
	 * Returns the hashmap used to store security events for this user. Used by the
	 * IntrusionDetector.
	 */
	
	public Struct function getEventMap();
	
}