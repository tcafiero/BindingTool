class ScanServiceModel < ScanModel

	def initialize(document)
		@document=document
  end

	def iterateDo
	end

	def iterateDoEnd
	end

	def interfaceDo
	end

	def interfaceDoEnd
	end

	def methodDo
	end

	def methodDoEnd
	end

	def signalDo
	end

	def signalDoEnd
	end


	def argDo
	end

	def errorDo
	end


	def iteratearg(method)
		method.elements.each("Arg") {|arg|
			begin
				@argname=arg.attributes["Name"]
				@argtype=arg.attributes["Type"]
				@argdirection=arg.attributes["Direction"]
			rescue
				puts "Fatal error - in Service: #{@servicename} method/signal: #{@methodname} missing or wrong name, type, direction"
				exit 1
			end
			argDo
		}
	end

	def iterateerror(method, oneshot=true)
		method.elements.each("ErrorSubset") {|err|
			@errorref=err.attributes["ErrorRef"]
			errorDo
			if oneshot == true then
				break
			end
		}
	end

	def iteratemethodstrategy(method)
			iteratearg(method)
			iterateerror(method)
	end

	def iteratemethod(interface)
		interface.elements.each("Method") {|method|
			begin
				@methodname=method.attributes["Name"]
			rescue
				puts "Fatal error: there is not a method field name in service #{@servicename}"
				exit 1
			end
			begin
				@methodannotation=method.attributes["Annotation"]
			rescue
				@methodannotation=""
			end
			methodDo
			iteratemethodstrategy(method)
			methodDoEnd
		}
	end

	def iteratesignalstrategy(signal)
		iteratearg(signal)	
	end

	def iteratesignal(interface)
		interface.elements.each("Signal") {|signal|
			begin
				@signalname=signal.attributes["Name"]
			rescue
				puts "Fatal error: there is not a signal field name in service #{@servicename}"
				exit 1
			end
			begin
				@signalannotation=signal.attributes["Annotation"]
			rescue
				@signalannotation=""
			end
			signalDo
			iteratesignalstrategy(signal)
			signalDoEnd
			}
	end

	def iterateinterfacestrategy(interface)
		iteratemethod(interface)
		iteratesignal(interface)
	end
	
	def iterateinterface(service)
	service.elements.each("Interface") {|interface|
		@interfacename=interface.attributes["Name"]
		begin
			@interfaceannotation=interface.attributes["Annotation"]
		rescue
			@interfaceannotation=""
		end
		interfaceDo
		iterateinterfacestrategy(interface)
		interfaceDoEnd
		}
	end

  def iterate(xpath)
    @document.elements.each(xpath) {|service|
      @servicename=service.attributes["Name"]
      begin
        @serviceannotation=service.attribute["Annotation"]
      rescue
        @serviceannotation=""
      end
			iterateDo
			iterateinterface(service)
			iterateDoEnd
      }
  end
end
