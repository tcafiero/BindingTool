class MakeIntrospect < ScanServiceModel
	def buildinterfacename(interfacename)
		"#{$MarelliNamespace.gsub /_/, "."}.#{interfacename}"
	end

	def iterateDo
		@nodeintrospect=$stddescription.add_element 'node', {'name' => "#{@servicename} automatically generated with BindingTool Rel. #{$bindingToolRel}"}
	end

	def interfaceDo
		@interfaceintrospect=@nodeintrospect.add_element 'interface', {"name" => "#{buildinterfacename(@interfacename)}"}
		annotationintrospect=@interfaceintrospect.add_element 'annotation', {"name" => "nameprefix", "value" => $MarelliNamespace}
	end

	def methodDo
		@methodintrospect=@interfaceintrospect.add_element 'method', {"name" => @methodname}
		argintrospect=@methodintrospect.add_element 'arg', {"name" => 'error', "direction" => 'out', "type" => 'i'}
	end

	def signalDo
		@methodintrospect=@interfaceintrospect.add_element 'signal', {"name" => @signalname}
	end

	def argDo
		if  $dataType[@argtype].nil? then
			if $enum[@argtype].nil? then
				puts "Fatal error in method: #{@methodname} - Agrument: #{@argname} refer to wrong data type."
				exit
			end
			dbustranslation="u"
		else
			dbustranslation=$dataType[@argtype]['dbus']
		end
		argintrospect=@methodintrospect.add_element 'arg', {"name" => @argname, "direction" => @argdirection, "type" => dbustranslation}
	end

	def errorDo
		argintrospect=@methodintrospect.add_element 'arg', {"name" => 'progerror', "direction" => 'out', "type" => 'i'}
	end
end
