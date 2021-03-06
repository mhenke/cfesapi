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
<cfcomponent displayname="SecurityConfigurationWrapper" implements="cfesapi.org.owasp.esapi.SecurityConfiguration" output="false" hint="Simple wrapper implementation of {@link SecurityConfiguration}. This allows for easy subclassing and property fixups for unit tests. Note that there are some compilers have issues with Override attributes on methods implementing a interface method with some compilers. Technically Override on such methods is a 1.6 feature so they are commented out here.">
	
	<cfscript>
		instance.wrapped = "";
	</cfscript>
	
	<cffunction access="public" returntype="SecurityConfigurationWrapper" name="init" output="false"
	            hint="Constructor wrapping the given configuration.">
		<cfargument required="true" type="cfesapi.org.owasp.esapi.SecurityConfiguration" name="wrapped" hint="The configuration to wrap."/>
	
		<cfscript>
			instance.wrapped = arguments.wrapped;
		
			return this;
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="SecurityConfiguration" name="getWrappedSecurityConfiguration" output="false"
	            hint="Access the wrapped configuration. The wrapped configuration.">
		
		<cfscript>
			return instance.wrapped;
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getApplicationName" output="false">
		
		<cfscript>
			return instance.wrapped.getApplicationName();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getLogImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getLogImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getAuthenticationImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getAuthenticationImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getEncoderImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getEncoderImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getAccessControlImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getAccessControlImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getIntrusionDetectionImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getIntrusionDetectionImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getRandomizerImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getRandomizerImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getEncryptionImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getEncryptionImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getValidationImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getValidationImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" name="getValidationPattern" output="false">
		<cfargument required="true" type="String" name="key"/>
	
		<cfscript>
			return instance.wrapped.getValidationPattern(arguments.key);
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getExecutorImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getExecutorImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getHTTPUtilitiesImplementation" output="false">
		
		<cfscript>
			return instance.wrapped.getHTTPUtilitiesImplementation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="binary" name="getMasterKey" output="false">
		
		<cfscript>
			return instance.wrapped.getMasterKey();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" name="getUploadDirectory" output="false">
		
		<cfscript>
			return instance.wrapped.getUploadDirectory();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" name="getUploadTempDirectory" output="false">
		
		<cfscript>
			return instance.wrapped.getUploadTempDirectory();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getEncryptionKeyLength" output="false">
		
		<cfscript>
			return instance.wrapped.getEncryptionKeyLength();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="binary" name="getMasterSalt" output="false">
		
		<cfscript>
			return instance.wrapped.getMasterSalt();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="Array" name="getAllowedExecutables" output="false">
		
		<cfscript>
			return instance.wrapped.getAllowedExecutables();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="Array" name="getAllowedFileExtensions" output="false">
		
		<cfscript>
			return instance.wrapped.getAllowedFileExtensions();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getAllowedFileUploadSize" output="false">
		
		<cfscript>
			return instance.wrapped.getAllowedFileUploadSize();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getPasswordParameterName" output="false">
		
		<cfscript>
			return instance.wrapped.getPasswordParameterName();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getUsernameParameterName" output="false">
		
		<cfscript>
			return instance.wrapped.getUsernameParameterName();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getEncryptionAlgorithm" output="false">
		
		<cfscript>
			return instance.wrapped.getEncryptionAlgorithm();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getCipherTransformation" output="false">
		
		<cfscript>
			return instance.wrapped.getCipherTransformation();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="setCipherTransformation" output="false">
		<cfargument required="true" type="String" name="cipherXform"/>
	
		<cfscript>
			return instance.wrapped.setCipherTransformation(arguments.cipherXform);
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="useMACforCipherText" output="false">
		
		<cfscript>
			return instance.wrapped.useMACforCipherText();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="overwritePlainText" output="false">
		
		<cfscript>
			return instance.wrapped.overwritePlainText();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getIVType" output="false">
		
		<cfscript>
			return instance.wrapped.getIVType();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getFixedIV" output="false">
		
		<cfscript>
			return instance.wrapped.getFixedIV();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getHashAlgorithm" output="false">
		
		<cfscript>
			return instance.wrapped.getHashAlgorithm();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getHashIterations" output="false">
		
		<cfscript>
			return instance.wrapped.getHashIterations();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getCharacterEncoding" output="false">
		
		<cfscript>
			return instance.wrapped.getCharacterEncoding();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getAllowMultipleEncoding" output="false">
		
		<cfscript>
			return instance.wrapped.getAllowMultipleEncoding();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getAllowMixedEncoding" output="false">
		
		<cfscript>
			return instance.wrapped.getAllowMixedEncoding();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="Array" name="getDefaultCanonicalizationCodecs" output="false">
		
		<cfscript>
			return instance.wrapped.getDefaultCanonicalizationCodecs();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getDigitalSignatureAlgorithm" output="false">
		
		<cfscript>
			return instance.wrapped.getDigitalSignatureAlgorithm();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getDigitalSignatureKeyLength" output="false">
		
		<cfscript>
			return instance.wrapped.getDigitalSignatureKeyLength();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getRandomAlgorithm" output="false">
		
		<cfscript>
			return instance.wrapped.getRandomAlgorithm();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getAllowedLoginAttempts" output="false">
		
		<cfscript>
			return instance.wrapped.getAllowedLoginAttempts();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getMaxOldPasswordHashes" output="false">
		
		<cfscript>
			return instance.wrapped.getMaxOldPasswordHashes();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" name="getQuota" output="false">
		<cfargument required="true" type="String" name="eventName"/>
	
		<cfscript>
			return instance.wrapped.getQuota(arguments.eventName);
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" name="getResourceFile" output="false">
		<cfargument required="true" type="String" name="filename"/>
	
		<cfscript>
			return instance.wrapped.getResourceFile(arguments.filename);
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getForceHttpOnlySession" output="false">
		
		<cfscript>
			return instance.wrapped.getForceHttpOnlySession();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getForceSecureSession" output="false">
		
		<cfscript>
			return instance.wrapped.getForceSecureSession();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getForceHttpOnlyCookies" output="false">
		
		<cfscript>
			return instance.wrapped.getForceHttpOnlyCookies();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getForceSecureCookies" output="false">
		
		<cfscript>
			return instance.wrapped.getForceSecureCookies();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getMaxHttpHeaderSize" output="false">
		
		<cfscript>
			return instance.wrapped.getMaxHttpHeaderSize();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" name="getResourceStream" output="false">
		<cfargument required="true" type="String" name="filename"/>
	
		<cfscript>
			return instance.wrapped.getResourceStream(arguments.filename);
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="void" name="setResourceDirectory" output="false">
		<cfargument required="true" type="String" name="dir"/>
	
		<cfscript>
			instance.wrapped.setResourceDirectory(arguments.dir);
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getResponseContentType" output="false">
		
		<cfscript>
			return instance.wrapped.getResponseContentType();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getHttpSessionIdName" output="false">
		
		<cfscript>
			return instance.wrapped.getHttpSessionIdName();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getRememberTokenDuration" output="false">
		
		<cfscript>
			return instance.wrapped.getRememberTokenDuration();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getSessionIdleTimeoutLength" output="false">
		
		<cfscript>
			return instance.wrapped.getSessionIdleTimeoutLength();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getSessionAbsoluteTimeoutLength" output="false">
		
		<cfscript>
			return instance.wrapped.getSessionAbsoluteTimeoutLength();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getLogEncodingRequired" output="false">
		
		<cfscript>
			return instance.wrapped.getLogEncodingRequired();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getLogApplicationName" output="false">
		
		<cfscript>
			return instance.wrapped.getLogApplicationName();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getLogServerIP" output="false">
		
		<cfscript>
			return instance.wrapped.getLogServerIP();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getLogLevel" output="false">
		
		<cfscript>
			return instance.wrapped.getLogLevel();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getLogFileName" output="false">
		
		<cfscript>
			return instance.wrapped.getLogFileName();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="numeric" name="getMaxLogFileSize" output="false">
		
		<cfscript>
			return instance.wrapped.getMaxLogFileSize();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" name="getWorkingDirectory" output="false">
		
		<cfscript>
			return instance.wrapped.getWorkingDirectory();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="Array" name="getAdditionalAllowedCipherModes" output="false">
		
		<cfscript>
			return instance.wrapped.getAdditionalAllowedCipherModes();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="Array" name="getCombinedCipherModes" output="false">
		
		<cfscript>
			return instance.wrapped.getCombinedCipherModes();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getPreferredJCEProvider" output="false">
		
		<cfscript>
			return instance.wrapped.getPreferredJCEProvider();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getDisableIntrusionDetection" output="false">
		
		<cfscript>
			return instance.wrapped.getDisableIntrusionDetection();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="String" name="getKDFPseudoRandomFunction" output="false">
		
		<cfscript>
			return instance.wrapped.getKDFPseudoRandomFunction();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="boolean" name="getLenientDatesAccepted" output="false">
		
		<cfscript>
			return instance.wrapped.getLenientDatesAccepted();
		</cfscript>
		
	</cffunction>
	
</cfcomponent>