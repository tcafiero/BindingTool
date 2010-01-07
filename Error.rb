class Error < ScanModel
   def initialize(document)
     @document=document
		 $error=Hash.new
		 @errorvalue=-1
     begin
      @servicename=@document.root.elements["Service"].attributes["Name"].gsub /\./, "_"
			$errornamespace = "e_com_MM_#{@servicename}_"
     rescue
      puts "Fatal error: there is not a Service name il xml file."
      exit 1
     end
   end
  def iterate(xpath)
		@document.elements.each(xpath) {|item|
      errorname=item.attributes["Name"]
      begin
        errorannotation=item.attribute["Annotation"]
      rescue
        errorannotation="(NO Annotation)"
      end
      $error[errorname]=[errorannotation, "#{@errorvalue}"]
      $includeFileOut.puts "/* error: #{$errornamespace}#{errorname} - Annotation\n"
#      $includeFileOut.puts errorannotation == "" ? "(NO Annotation)" : errorannotation
      $includeFileOut.puts errorannotation
      $includeFileOut.puts "*/"
      $includeFileOut.puts "#define #{$errornamespace}#{errorname} #{@errorvalue}\n\n\n"
			@errorvalue -= 1
    }    
  end
end
