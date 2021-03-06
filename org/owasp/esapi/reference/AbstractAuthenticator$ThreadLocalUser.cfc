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
<cfcomponent displayname="ThreadLocalUser" extends="cfesapi.org.owasp.esapi.lang.ThreadLocal" output="false">

	<cfscript>
		instance.ESAPI = "";
	</cfscript>
	
	<cffunction access="public" returntype="AbstractAuthenticator$ThreadLocalUser" name="init" output="false">
		<cfargument required="true" type="cfesapi.org.owasp.esapi.ESAPI" name="ESAPI"/>
	
		<cfscript>
			instance.ESAPI = arguments.ESAPI;
			return this;
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="cfesapi.org.owasp.esapi.User" name="initialValue" output="false">
		
		<cfscript>
			return newComponent("cfesapi.org.owasp.esapi.User$ANONYMOUS").init(instance.ESAPI);
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="cfesapi.org.owasp.esapi.User" name="getUser" output="false">
		
		<cfscript>
			return super.get();
		</cfscript>
		
	</cffunction>
	
	<cffunction access="public" returntype="void" name="setUser" output="false">
		<cfargument required="true" type="cfesapi.org.owasp.esapi.User" name="newUser"/>
	
		<cfscript>
			super.set(arguments.newUser);
		</cfscript>
		
	</cffunction>
	
</cfcomponent>