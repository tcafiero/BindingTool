class MakeProxyImp < ScanServiceModel
	def initialize(document)
	filename="#{$outdir}#{$rootname}_proxy_imp.h"
  @file=open(filename, 'w')
	@document=document
	@Primitive={
	'BYTE' => "uint8_t",
	'BOOLEAN' => "bool",
	'INT16' => "int16_t",
	'UINT16' => "uint16_t",
	'INT32' => "int32_t",
	'UINT32' => "uint32_t",
	'INT64' => "int64_t",
	'UINT64' => "uint64_t",
	'DOUBLE' => "double",
	'STRING' => "std::string"
	}
	@header = <<'SINGLE_QUOTED'
/*
 *	This file was automatically generated by BindingTool; DO NOT EDIT!
 *  Code produced automatically widh BindingTool Rel. #{$bindingToolRel}
 */

#ifndef __BindingTool__#{$rootname}_proxy_imp_h__PROXY_MARSHAL_H
#define __BindingTool__#{$rootname}_proxy_imp_h__PROXY_MARSHAL_H

#include \"#{$rootname}_proxy.h\"
#include \"#{$rootname}_dataType.h\"

#include \"CMMString.h\"

SINGLE_QUOTED

	@footer =	<<'SINGLE_QUOTED'

#endif /*__BindingTool__#{$rootname}_proxy_imp_h__PROXY_MARSHAL_H*/
SINGLE_QUOTED

	@glueclasstemplate = <<'SINGLE_QUOTED'
class #{@classname}_proxy_imp : public #{@classname}_proxy
{
public:

    #{@classname}_proxy_imp() : #{@classname}_proxy() { }

    virtual ~#{@classname}_proxy_imp() {}

    /* methods exported by this interface,
     * this functions will invoke the corresponding methods on the remote objects
     */

    // in : data to be exported to the bus. Automatic conversion from const #{@classname}_structtest& to const ::DBUS::Struct& using #{@classname}_structtest cast method
    // out : data to be retrived from the bus(answer). Automatic conversion from #{@classname}_structtest to ::DBUS::Struct using #{@classname}_structtest cast method

    // TODO : if string in parameter (in or out), how to do ?
    // in : dynamic cast a const CMMString& to a const stl:string&
    // out : dynamic cast not possible ... temporay variable must be used

#{@methodList}

    /* signal handlers for this interface
     */

    // must be implemented by user if needed
    // data comming from DBUS

#{@signalList}

  private:

    // implement mother call of do type conversion
    // all data are input, conversion from const DBus::Struct& to const #{@classname}_structtest& done by copy constructor
    // conversion from const stl::string& to const CMMString& explicit or by copy constructor (not implementaed yet)

#{@privateSignalList}

};
SINGLE_QUOTED

@privateSignalTemplate = <<'SINGLE_QUOTED'
	void #{@signalname}(#{@argBaseTypeList})
	{
#{@conversionList}
		#{@signalname}_imp(#{@argNameList});
	}

SINGLE_QUOTED

		@file.puts eval( '"' + @header + '"')
	end

	def iterateDoEnd
		@file.puts eval( '"' + @footer + '"')
		@file.close
	end
	def interfaceDo
		@methodList=""
		@signalList=""
		@privateSignalList=""
	end

	def interfaceDoEnd
		@file.puts eval( '"' + @glueclasstemplate + '"')
	end

	def argDoIn
		if @argdirection == "in" then
			cpptype=@argtype
			if @Primitive[cpptype].nil? then
				if $enum[cpptype].nil? then
					cpptype = "#{$MarelliNamespace}_#{@servicename}_#{cpptype}"
				else
					cpptype = "uint32_t"
				end
			else
				cpptype = @Primitive[cpptype]
			end
			@argComplexTypeList += @argComplexTypeListSeparator+"const #{cpptype} &#{@argname}"
			@argComplexTypeListSeparator = ", "
			@argNameList += @argNameListSeparator+@argname
			@argNameListSeparator = ", "
		end
	end

	def argDoOut
		if @argdirection == "out" then
			cpptype=@argtype
			if @Primitive[cpptype].nil? then
				if $enum[cpptype].nil? then
					cpptype = "#{$MarelliNamespace}_#{@servicename}_#{cpptype}"
				else
					cpptype = "uint32_t"
				end
			else
				cpptype = @Primitive[cpptype]
			end
			@argComplexTypeList += @argComplexTypeListSeparator+"#{cpptype} &p_#{@argname}"
			@argComplexTypeListSeparator = ", "
			@argNameList += @argNameListSeparator+"p_"+@argname
			@argNameListSeparator = ", "
		end
	end

	def argDoInSimpleType
		argname = @argname
		if @argdirection == "in" then
			if @Primitive[@argtype].nil? then
				if $enum[@argtype].nil? then
					cpptype = $dataType[@argtype]['cpp']
				else
					cpptype = "uint32_t"
				end
			else
				cpptype = @Primitive[@argtype]
			end
			@argBaseTypeList += @argBaseTypeListSeparator+"const #{cpptype} &#{@argname}"
			@argBaseTypeListSeparator = ", "
			@argNameList += @argNameListSeparator+argname
			@argNameListSeparator = ", "
		end
	end

	def argDoOutSimpleType
		argname=@argname
		if @argdirection == "out" then
			if @Primitive[@argtype].nil? then
				if $enum[@argtype].nil? then
					cpptype = $dataType[@argtype]['cpp']
				else
					cpptype = "uint32_t"
				end
			else
				cpptype = @Primitive[@argtype]
			end
			@argBaseTypeList += @argBaseTypeListSeparator+"#{cpptype} &#{@argname}"
			@argBaseTypeListSeparator = ", "
			@argNameList += @argNameListSeparator+argname
			@argNameListSeparator = ", "
		end
	end


	def argDoSignal
		argname = @argname
		if @argdirection == "out" then
			if @Primitive[@argtype].nil? then
				if $enum[@argtype].nil? then
					cpptype = $dataType[@argtype]['cpp']
				else
					cpptype = "uint32_t"
				end
			else
				cpptype = @Primitive[@argtype]
			end
			if @argtype == "STRING" then
				argname="l_#{@argname}"
				@conversionList += "\t\tCMMString l_#{@argname}(#{@argname}.c_str(), -1, CMMSTRING_UTF8);\n"
			end
			@argBaseTypeList += @argBaseTypeListSeparator+"const #{cpptype} &#{@argname}"
			@argBaseTypeListSeparator = ", "
			@argNameList += @argNameListSeparator+argname
			@argNameListSeparator = ", "
		end
	end


#definisci la strategia di iterazione sugli elementi contenuti in "Interface"
	def iterateinterfacestrategy(interface)
		@classname="#{$MarelliNamespace}_#{@interfacename}"
		@methodList=""
		@signalList=""
		@privateSignalList=""

#Method
		@methodList=""
		#definisci la strategia di iterazione sugli elementi contenuti in "Method"
		def self.iteratemethodstrategy(method)

			#stabilisci quale azione eseguire quando si sono acquisiti i dati di un argomento
			#nello specifico caso si considerano solo gli argomenti con direzione "in"
			def self.argDo
				argDoIn
			end
			#quindi iterare sugli argomenti
			iteratearg(method)

			#stabilisci quale azione eseguire quando si sono acquisiti i dati di un argomento
			#nello specifico caso si considerano solo gli argomenti con direzione "out"
			def self.argDo
				argDoOut
			end
			#quindi iterare sugli argomenti
			iteratearg(method)

			#stabilisci quale azione eseguire quando è presente almeno un elemento
			#in "ErrorSubset"
			#nello specifico caso si aggiunge alla lista degli argomenti un argomento di errore
			def self.errorDo
			@argComplexTypeList += @argComplexTypeListSeparator+"int32_t &progerror"
			@argComplexTypeListSeparator = ", "
			@argNameList += @argNameListSeparator+"progerror"
			@argNameListSeparator = ", "
			end
			iterateerror(method)
		end
		#end strategia di scansione di "Method"


		@methodList=""
		#definisce l''azione da compiere prima di attuare la strategia di iterazione su "Method"
		def self.methodDo
			@argComplexTypeList = ""
			@argComplexTypeListSeparator = ""
			@argNameList = ""
			@argNameListSeparator = ""
		end

		#definisce l'azione da compiere dopo l'attuazione della strategia di iterazione su "Method"
		def self.methodDoEnd
			@methodList += "\tint32_t #{@methodname}_imp(#{@argComplexTypeList})\n\t{\n\t\treturn (#{@methodname}(#{@argNameList}));\n\t}\n\n"
		end
		
		#quindi itera sui "Method"
		iteratemethod(interface)


#Signal
		@signalList=""
		#definisci la strategia di iterazione sugli elementi contenuti in "Signal"
		def self.iteratesignalstrategy(signal)
	def argDoOut
		if @argdirection == "out" then
			cpptype=@argtype
			if @Primitive[cpptype].nil? then
				if $enum[cpptype].nil? then
					cpptype = "#{$MarelliNamespace}_#{@servicename}_#{cpptype}"
				else
					cpptype = "uint32_t"
				end
			else
				cpptype = @Primitive[cpptype]
			end
			if cpptype == "std::string" then
				cpptype = "CMMString"
			end
			@argComplexTypeList += @argComplexTypeListSeparator+"const #{cpptype} &p_#{@argname}"
			@argComplexTypeListSeparator = ", "
			@argNameList += @argNameListSeparator+"p_"+@argname
			@argNameListSeparator = ", "
		end
	end

			iteratearg(signal)
			def self.errorDo
				@argComplexTypeList += @argComplexTypeListSeparator+"int32_t &progerror"
				@argComplexTypeListSeparator = ", "
				@argNameList += @argNameListSeparator+"progerror"
				@argNameListSeparator = ", "
			end
			iterateerror(signal)
		end

		#definisce l'azione da compiere prima dell'attuazione della strategia di iterazione su "Signal"
		def self.signalDo
			@argComplexTypeList=""
			@argComplexTypeListSeparator=""
			@argBaseTypeList=""
			@argBaseTypeListSeparator=""
			@argNameList=""
			@argNameListSeparator=""
			@conversionlist=""
		end

		#definisce l'azione da compiere dopo l'attuazione della strategia di iterazione su "Signal"
		def self.signalDoEnd
			@signalList += "\tvirtual void #{@signalname}_imp(#{@argComplexTypeList}) {}\n\n"
		end

		#quindi itera sui "Signal"
		iteratesignal(interface)

#Signal
		@privateSignalList=""
		@conversionList=""
		def self.iteratesignalstrategy(signal)

			#stabilisci quale azione eseguire quando si sono acquisiti i dati di un argomento
			#nello specifico caso si considerano solo gli argomenti con direzione "in"
			def self.argDo
				argDoSignal
			end
			#quindi iterare sugli argomenti
			iteratearg(signal)

			#stabilisci quale azione eseguire quando è presente almeno un elemento
			#in "ErrorSubset"
			#nello specifico caso si aggiunge alla lista degli argomenti un argomento di errore
			def self.errorDo
				@argBaseTypeList += @argBaseTypeListSeparator+"int32_t &progerror"
				@argBaseTypeListSeparator = ", "
				@argNameList += @argNameListSeparator+"progerror"
				@argNameListSeparator = ", "
			end
			iterateerror(signal)
		end
		#end strategia di scansione di "Method"
		#definisce l''azione da compiere prima di attuare la strategia di iterazione su "Method"
		def self.signalDo
			@argComplexTypeList=""
			@argComplexTypeListSeparator=""
			@argBaseTypeList=""
			@argBaseTypeListSeparator=""
			@argNameList=""
			@argNameListSeparator=""
		end

		#definisce l'azione da compiere dopo l'attuazione della strategia di iterazione su "Method"
		def self.signalDoEnd
			@privateSignalList += eval( '"' + @privateSignalTemplate + '"')
		end

		iteratesignal(interface)
	end
end

	