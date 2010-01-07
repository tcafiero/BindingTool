class Enum < ScanModel
   def initialize(document)
     @document=document
		 $enum=Hash.new
     begin
      @servicename=@document.root.elements["Service"].attributes["Name"].gsub /\./, "_"
     rescue
      puts "Fatal error: there is not a Service name il xml file."
      exit 1
     end
   end
  def iterate(xpath)
		@document.elements.each(xpath) {|item|
      enumname=item.attributes["Name"]
      begin
        enumannotation=item.attribute["Annotation"]
      rescue
        enumannotation=""
      end
      $enum[enumname]="i"
      memberset=""
      separator=""
      item.elements.each("Element") {|member|
        begin
          enummembername=member.attributes["Name"]
        rescue
          puts "Fatal error: there is not a enum field name in enum: #{@enumname}"
          exit 1
        end
        begin
          enummembervalue=member.attributes["Value"]
        rescue
          puts "Fatal error: there is not a enum field value in enum: #{@enumname}"
          exit 1
        end
        memberset <<= "#{separator}#{$MarelliNamespace.upcase}_#{@servicename.upcase}_#{enumname.upcase}_#{enummembername.upcase} = #{enummembervalue}"
        separator=", "
      }
      $includeFileOut.puts "/* enum: #{enumname} - Annotation\n"
      $includeFileOut.puts enumannotation == "" ? "(NO Annotation)" : enumannotation
      $includeFileOut.puts "*/"
      $includeFileOut.puts "typedef enum {#{memberset}} t_com_MM_#{@servicename}_#{enumname};\n\n\n"
    }    
  end
end
