class DataType < ScanModel
   def initialize(document)

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
      @document=document
      $dataType=Hash.new
     begin
      @servicename=@document.root.elements["Service"].attributes["Name"].gsub /\./, "_"
     rescue
      puts "Fatal error: there is not a Service name il xml file."
      exit 1
     end
      ['VARIANT','BYTE','BOOLEAN','INT16',
      'UINT16','INT32','UINT32','INT64','UINT64','DOUBLE','STRING','PATH','SIGNATURE','INVALID'].each do |c|
         $dataType[c]={}
         $dataType[c]['dbus'] = case c
         when "VARIANT" then "v"
         when 'BYTE'then "y"
         when 'BOOLEAN'then "b"
         when 'INT16'then "n"
         when 'UINT16'then "q"
         when 'INT32'then "i"
         when 'UINT32'then "u"
         when 'INT64'then "x"
         when 'UINT64'then "t"
         when 'DOUBLE'then "d"
         when 'STRING'then "s"
         when 'PATH' then "o"
         when 'SIGNATURE' then "g"
         else ""
         end
         $dataType[c]['cpp'] = case c
         when 'VARIANT' then "Variant"
         when 'BYTE'then "uint8_t"
         when 'BOOLEAN'then "bool"
         when 'INT16'then "int16_t"
         when 'UINT16'then "uint16_t"
         when 'INT32'then "int32_t"
         when 'UINT32'then "uint32_t"
         when 'INT64'then "int64_t"
         when 'UINT64'then "uint64_t"
         when 'DOUBLE'then "double"
         when 'STRING'then "std::string"
         when 'PATH' then "Path"
         when 'SIGNATURE' then "Signature"
         else "Invalid"
         end
      end
   end
  def iterate(xpath)
		@document.elements.each(xpath) {|item|
      datatypename=item.attributes["Name"]
      $dataType[datatypename]={}
      begin
        datatypeannotation=item.attribute["Annotation"]
      rescue
        datatypeannotation=""
      end
      dbusset=""
      cppset=""
      separator=""
      item.elements.each("Element") {|member|
        begin
          datatypemembername=member.attributes["Name"]
        rescue
          puts "Fatal error: there is not a DataType field name in DataType: #{@datatypename}"
          exit 1
        end
        begin
          datatypememberisarray=member.attributes["IsArray"]
        rescue
          datatypememberisarray="not"
        end
        begin
          datatypemembertype=member.attributes["Type"]
        rescue
          puts "Fatal error: there is not a DataType field type in DataType: #{datatypename}"
          exit 1
        end
        begin
          datatypememberdimension=member.attributes["Dimension"]
        rescue
          datatypememberdimension="0"
        end
         if $dataType[datatypemembertype].nil? && $enum[datatypemembertype].nil? then
            puts "Error DataType:#{datatypemembername} refers to type: #{datatypemembertype} not previously defined"
            exit
         else
            dbustype = $dataType[datatypemembertype].nil? ? "i" : $dataType[datatypemembertype]['dbus']
            cpptype = $dataType[datatypemembertype].nil? ? "UINT32" : datatypemembertype
            if @Primitive[cpptype].nil? then
              cpptype = "#{$MarelliNamespace}_#{@servicename}_#{cpptype}_DBUS"
            else
              cpptype = @Primitive[cpptype]
            end
            dbusset <<= (datatypememberisarray == "yes")? "a" + dbustype : dbustype
            cppset <<= (datatypememberisarray == "yes")? "#{separator}std::vector < #{cpptype} >" : "#{separator}#{cpptype}"
            separator = ", "
         end
      }
      if item.elements.size < 2 then
        $dataType[datatypename]['dbus'] = dbusset
        $dataType[datatypename]['cpp'] = "#{cppset}"
      else
        $dataType[datatypename]['dbus'] = "(#{dbusset})"
        $dataType[datatypename]['cpp'] = "::DBus::Struct < #{cppset} >"
      end
      $includeFileOut.puts "/* #{datatypename} - Annotation\n"
      $includeFileOut.puts datatypeannotation == "" ? "(NO Annotation)" : @annotation
      $includeFileOut.puts "DBUS parameter specification: "+$dataType[datatypename]['dbus']
      $includeFileOut.puts "*/"
      $includeFileOut.puts "typedef #{$dataType[datatypename]['cpp']} #{$MarelliNamespace}_#{@servicename}_#{datatypename}_DBUS;\n\n\n"
    }
  end
end
