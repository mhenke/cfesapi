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
<cfcomponent extends="BaseValidationRule" output="false" hint="A validator performs syntax and possibly semantic validation of a single piece of data from an untrusted source.">

	<cfscript>
		instance.minValue = newJava("java.lang.Integer").MIN_VALUE;
		instance.maxValue = newJava("java.lang.Integer").MAX_VALUE;
	</cfscript>

	<cffunction access="public" returntype="IntegerValidationRule" name="init" output="false">
		<cfargument type="cfesapi.org.owasp.esapi.ESAPI" name="ESAPI" required="true"/>
		<cfargument type="String" name="typeName" required="true"/>
		<cfargument type="cfesapi.org.owasp.esapi.Encoder" name="encoder" required="true"/>
		<cfargument type="numeric" name="minValue" required="false"/>
		<cfargument type="numeric" name="maxValue" required="false"/>

		<cfscript>
			super.init(arguments.ESAPI, arguments.typeName, arguments.encoder);

			if(structKeyExists(arguments, "minValue")) {
				instance.minValue = arguments.minValue;
			}
			if(structKeyExists(arguments, "maxValue")) {
				instance.maxValue = arguments.maxValue;
			}

			return this;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="any" name="getValid" output="false"
	            hint="numeric">
		<cfargument type="String" name="context" required="true"/>
		<cfargument type="String" name="input" required="true"/>
		<cfargument type="cfesapi.org.owasp.esapi.ValidationErrorList" name="errorList" required="false"/>

		<cfscript>
			if(structKeyExists(arguments, "errorList")) {
				return super.getValid(argumentCollection=arguments);
			}

			return safelyParse(arguments.context, arguments.input);
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="any" name="safelyParse" output="false"
	            hint="numeric">
		<cfargument type="String" name="context" required="true"/>
		<cfargument type="String" name="input" required="true"/>

		<cfset var local = {}/>

		<cfscript>
			// do not allow empty Strings such as "   " - so trim to ensure isEmpty catches "    "
			if(structKeyExists(arguments, "input"))
				arguments.input = arguments.input.trim();

			if(newJava("org.owasp.esapi.StringUtilities").isEmpty(arguments.input)) {
				if(instance.allowNull) {
					return "";
				}
				throwError(newComponent("cfesapi.org.owasp.esapi.errors.ValidationException").init(ESAPI=instance.ESAPI, userMessage=arguments.context & ": Input number required", logMessage="Input number required: context=" & arguments.context & ", input=" & arguments.input, context=arguments.context));
			}

			// canonicalize
			local.canonical = instance.encoder.canonicalize(arguments.input);

			if(instance.minValue > instance.maxValue) {
				throwError(newComponent("cfesapi.org.owasp.esapi.errors.ValidationException").init(ESAPI=instance.ESAPI, userMessage=arguments.context & ": Invalid number input: context", logMessage="Validation parameter error for number: maxValue ( " & instance.maxValue & ") must be greater than minValue ( " & instance.minValue & ") for " & arguments.context, context=arguments.context));
			}

			// validate min and max
			try {
				local.i = newJava("java.lang.Integer").valueOf(local.canonical);
				if(local.i < instance.minValue) {
					throwError(newComponent("cfesapi.org.owasp.esapi.errors.ValidationException").init(ESAPI=instance.ESAPI, userMessage="Invalid number input must be between " & instance.minValue & " and " & instance.maxValue & ": context=" & arguments.context, logMessage="Invalid number input must be between " & instance.minValue & " and " & instance.maxValue & ": context=" & arguments.context & ", input=" & arguments.input, context=arguments.context));
				}
				if(local.i > instance.maxValue) {
					throwError(newComponent("cfesapi.org.owasp.esapi.errors.ValidationException").init(ESAPI=instance.ESAPI, userMessage="Invalid number input must be between " & minValue & " and " & instance.maxValue & ": context=" & arguments.context, logMessage="Invalid number input must be between " & instance.minValue & " and " & instance.maxValue & ": context=" & arguments.context & ", input=" & arguments.input, context=arguments.context));
				}
				return local.i;
			}
			catch(java.lang.NumberFormatException e) {
				throwError(newComponent("cfesapi.org.owasp.esapi.errors.ValidationException").init(instance.ESAPI, arguments.context & ": Invalid number input", "Invalid number input format: context=" & arguments.context & ", input=" & arguments.input, e, arguments.context));
			}
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="any" name="sanitize" output="false">
		<cfargument type="String" name="context" required="true"/>
		<cfargument type="String" name="input" required="true"/>

		<cfset var local = {}/>

		<cfscript>
			local.toReturn = newJava("java.lang.Integer").valueOf(0);
			try {
				local.toReturn = safelyParse(arguments.context, arguments.input);
			}
			catch(cfesapi.org.owasp.esapi.errorsValidationException e) {
				// do nothing
			}
			return local.toReturn;
		</cfscript>

	</cffunction>

</cfcomponent>