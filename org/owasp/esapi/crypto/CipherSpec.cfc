<cfcomponent extends="cfesapi.org.owasp.esapi.util.Object" output="false" hint="Specifies all the relevant configuration data needed in constructing and using a javax.crypto.Cipher except for the encryption key.">

	<cfscript>
		instance.ESAPI = "";

		instance.cipher_xform_   = "";
		instance.keySize_        = ""; // In bits
		instance.blockSize_      = 16;   // In bytes! I.e., 128 bits!!!
		instance.iv_             = toBinary("");

		// Cipher transformation component. Format is ALG/MODE/PADDING
		CipherTransformationComponent = {
			ALG = createObject("component", "cfesapi.org.owasp.esapi.crypto.CipherTransformationComponent").init(1),
			MODE = createObject("component", "cfesapi.org.owasp.esapi.crypto.CipherTransformationComponent").init(2),
			PADDING = createObject("component", "cfesapi.org.owasp.esapi.crypto.CipherTransformationComponent").init(3)
		};
	</cfscript>

	<cffunction access="public" returntype="CipherSpec" name="init" output="false">
		<cfargument type="cfesapi.org.owasp.esapi.ESAPI" name="ESAPI" required="true">
		<cfargument type="any" name="cipher" required="false" hint="javax.crypto.Cipher">
		<cfargument type="String" name="cipherXform" required="false" hint="The cipher transformation">
		<cfargument type="numeric" name="keySize" required="false" hint="The key size (in bits).">
		<cfargument type="numeric" name="blockSize" required="false" hint="The block size (in bytes).">
		<cfargument type="binary" name="iv" required="false">
		<cfscript>
			instance.ESAPI = arguments.ESAPI;

			CryptoHelper = createObject("component", "cfesapi.org.owasp.esapi.crypto.CryptoHelper").init(instance.ESAPI);

			if (structKeyExists(arguments, "cipher")) {
				setCipherTransformation(arguments.cipher.getAlgorithm(), true);
				setBlockSize(arguments.cipher.getBlockSize());
				if ( !isNull(arguments.cipher.getIV()) ) {
					setIV(arguments.cipher.getIV());
				}
			}
			else {

				if (structKeyExists(arguments, "cipherXform")) {
					setCipherTransformation(arguments.cipherXform);
				}
				else {
					setCipherTransformation(instance.ESAPI.securityConfiguration().getCipherTransformation());
				}
				if (structKeyExists(arguments, "blockSize")) {
					setBlockSize(arguments.blockSize);
				}
				if (structKeyExists(arguments, "iv")) {
					setIV(arguments.iv);
				}
			}

			if (structKeyExists(arguments, "keySize")) {
				setKeySize(arguments.keySize);
			}
			else {
				setKeySize(instance.ESAPI.securityConfiguration().getEncryptionKeyLength());
			}

			return this;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="CipherSpec" name="setCipherTransformation" output="false" hint="Set the cipher transformation for this CipherSpec. This is only used by the CTOR CipherSpec(Cipher) and CipherSpec(Cipher, int).">
		<cfargument type="String" name="cipherXform" required="true" hint="The cipher transformation string; e.g., 'DESede/CBC/PKCS5Padding'.">
		<cfargument type="boolean" name="fromCipher" required="false" default="false" hint="If true, the cipher transformation was set via Cipher.getAlgorithm() which may only return the actual algorithm. In that case we check and if all 3 parts were not specified, then we specify the parts that were based on 'ECB' as the default cipher mode and 'NoPadding' as the default padding scheme.">
		<cfscript>
			assert(javaLoader().create("org.owasp.esapi.StringUtilities").notNullOrEmpty(arguments.cipherXform, true), "cipherXform may not be null or empty");
			local.parts = arrayLen(arguments.cipherXform.split("/"));
			assert (( !arguments.fromCipher ? (local.parts == 3) : true ), "Malformed cipherXform (" & arguments.cipherXform & '); must have form: "alg/mode/paddingscheme"');
			if ( arguments.fromCipher && (local.parts != 3)  ) {
					// Indicates cipherXform was set based on Cipher.getAlgorithm()
					// and thus may not be a *complete* cipher transformation.
				if ( local.parts == 1 ) {
					// Only algorithm was given.
					arguments.cipherXform &= "/ECB/NoPadding";
				} else if ( local.parts == 2 ) {
					// Only algorithm and mode was given.
					arguments.cipherXform &= "/NoPadding";
				} else if ( local.parts == 3 ) {
					// All threw parts provided. Do nothing. Could happen if not compiled with
					// assertions enabled.
					;	// Do nothing - shown only for completeness.
				} else {
					// Should never happen unless Cipher implementation is totally screwed up.
					throw(object=createObject("java", "java.lang.IllegalArgumentException").init('Cipher transformation "' & arguments.cipherXform & '" must have form "alg/mode/paddingscheme"'));
				}
			}
			assert(arrayLen(arguments.cipherXform.split("/")) == 3, "Implementation error setCipherTransformation()");
			instance.cipher_xform_ = arguments.cipherXform;
			return this;
		</cfscript>
	</cffunction>


	<cffunction acecss="public" returntype="String" name="getCipherTransformation" output="false" hint="Get the cipher transformation.">
		<cfscript>
			return instance.cipher_xform_;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="CipherSpec" name="setKeySize" output="false" hint="Set the key size for this CipherSpec.">
		<cfargument type="numeric" name="keySize" required="true" hint="The key size, in bits. Must be positive integer.">
		<cfscript>
			assert(keySize > 0, "keySize must be > 0; keySize=" & keySize);
			instance.keySize_ = arguments.keySize;
			return this;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="numeric" name="getKeySize" output="false" hint="Retrieve the key size, in bits.">
		<cfscript>
			return instance.keySize_;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="CipherSpec" name="setBlockSize" output="false" hint="Set the block size for this CipherSpec.">
		<cfargument type="numeric" name="blockSize" required="true" hint="The block size, in bytes. Must be positive integer.">
		<cfscript>
			assert(blockSize > 0, "blockSize must be > 0; blockSize=" & blockSize);
			instance.blockSize_ = arguments.blockSize;
			return this;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="numeric" name="getBlockSize" output="false" hint="Retrieve the block size, in bytes.">
		<cfscript>
			return instance.blockSize_;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="String" name="getCipherAlgorithm" output="false" hint="Retrieve the cipher algorithm.">
		<cfscript>
			return getFromCipherXform(CipherTransformationComponent.ALG);
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="String" name="getCipherMode" output="false" hint="Retrieve the cipher mode.">
		<cfscript>
			return getFromCipherXform(CipherTransformationComponent.MODE);
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="String" name="getPaddingScheme" output="false" hint="Retrieve the cipher padding scheme.">
		<cfscript>
			return getFromCipherXform(CipherTransformationComponent.PADDING);
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="binary" name="getIV" output="false" hint="Retrieve the initialization vector (IV).">
		<cfscript>
			return instance.iv_;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="CipherSpec" name="setIV" output="false" hint="Set the initialization vector (IV).">
		<cfargument type="binary" name="iv" required="true" hint="The byte array to set as the IV. A copy of the IV is saved. This parameter is ignored if the cipher mode does not require an IV.">
		<cfscript>
		assert(requiresIV() && (!isNull(arguments.iv) && len(arguments.iv) != 0), "Required IV cannot be null or 0 length");
		// Don't store a reference, but make a copy!
		if ( !isNull(arguments.iv) ) {	// Allow null IV for ECB mode.
			instance.iv_ = newByte( len(arguments.iv) );
			CryptoHelper.copyByteArray(arguments.iv, instance.iv_);
		}
		return this;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="boolean" name="requiresIV" output="false" hint="Return true if the cipher mode requires an IV.">
		<cfscript>
			local.cm = getCipherMode();

			// Add any other cipher modes supported by JCE but not requiring IV.
			// ECB is the only one I'm aware of that doesn't. Mode is not case
			// sensitive.
			if ( "ECB" == local.cm ) {
				return false;
			}
			return true;
		</cfscript>
	</cffunction>


	<cffunction access="public" returntype="String" name="toString" output="false" hint="A meaningful string describing this object.">
		<cfscript>
			local.sb = createObject("java", "java.lang.StringBuilder").init("CipherSpec: ");
			local.sb.append( getCipherTransformation() ).append("; keysize= ").append( javaCast("int", getKeySize()) );
			local.sb.append(" bits; blocksize= ").append( javaCast("int", getBlockSize()) ).append(" bytes");
			local.iv = getIV();
			local.ivLen = "";
			if ( !isNull(local.iv) ) {
				local.ivLen = "" & len(local.iv);	// Convert length to a string
			} else {
				local.ivLen = "[No IV present (not set or not required)]";
			}
			local.sb.append("; IV length = ").append( local.ivLen ).append(" bytes.");
			return local.sb.toString();
		</cfscript>
	</cffunction>

	<!--- equals --->
	<!--- hashCode --->
	<!--- canEqual --->

	<cffunction access="private" returntype="String" name="getFromCipherXform" output="false" hint="Split the current cipher transformation and return the requested part. ">
		<cfargument type="cfesapi.org.owasp.esapi.crypto.CipherTransformationComponent" name="component" required="true" hint="The component of the cipher transformation to return.">
		<cfscript>
	        local.part = arguments.component.ordinal();
			local.parts = getCipherTransformation().split("/");
			assert(arrayLen(local.parts) == 3, "Invalid cipher transformation: " & getCipherTransformation());
			return local.parts[local.part];
		</cfscript>
	</cffunction>


</cfcomponent>