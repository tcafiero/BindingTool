class DataTypeClass < ScanModel
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
@classtemplate = <<'SINGLE_QUOTED'
class  #{classname}
{
public:

  // default constructor, must do a complete initialisation of each m_data field
  #{classname}(void)
  {
#{initialization}
  }

  // copy constructor for automatic cast from DBUS::Struct to user class
  #{classname}(const #{classname}_DBUS& p_data) { m_data = p_data; }

  // classical destructor (no action)
  virtual ~#{classname}(void) {}

  // cast operator to enable automatic cast from user class to ::DBus::Struct
  // two cast needed : const and no const reference
  operator #{classname}_DBUS&() { return (m_data); }
  operator const #{classname}_DBUS&() const { return (m_data); }

  // affectation operator to copy a ::DBus::Struct to the user class
  #{classname}& operator = (const #{classname}_DBUS& p_data)
  {
    m_data = p_data;
    return (*this);
  }

  // multiple accessors (Get and Set)

  // All get method must be const to be able to get values from a const #{classname}&
  //
#{getList}

  // classical Set
#{setList}

private:
  // unique private member
  #{classname}_DBUS m_data;

};
SINGLE_QUOTED

		 @document=document
     begin
      @servicename=@document.root.elements["Service"].attributes["Name"].gsub /\./, "_"
     rescue
      puts "Fatal error: there is not a Service name il xml file."
      exit 1
     end
   end
  def iterate(xpath)
		@document.elements.each(xpath) {|item|
      datatypename=item.attributes["Name"]
      begin
        datatypeannotation=item.attribute["Annotation"]
      rescue
        datatypeannotation=""
      end
      separator=""
			initialization=""
			getList=""
			setList=""
			fieldorder=0
      if item.elements.size > 1 then
      item.elements.each("Element") {|member|
				fieldorder += 1
        begin
          datatypemembername=member.attributes["Name"]
        rescue
          puts "Fatal error: there is not a DataType field Name in DataType: #{datatypename}"
          exit 1
        end
        begin
          datatypememberisarray=member.attributes["IsArray"]
        rescue
          datatypememberisarray="not"
        end
        begin
          datatypemembertype=member.attributes["Type"]
          if $dataType[datatypemembertype].nil? && $enum[datatypemembertype].nil? then
            puts "Error DataType:#{datatypemembername} refers to type: #{datatypemembertype} not previously defined"
            exit
					else
            dbustype = $dataType[datatypemembertype].nil? ? "i" : $dataType[datatypemembertype]['dbus']
						if datatypememberisarray == "yes" then
							dbustype = "a"+dbustype
						end
            cpptype = $dataType[datatypemembertype].nil? ? "UINT32" : datatypemembertype
            if @Primitive[cpptype].nil? then
              cpptype = "#{$MarelliNamespace}_#{@servicename}_#{cpptype}_DBUS"
            else
              cpptype = @Primitive[cpptype]
            end
					end
				rescue
          puts "Fatal error: there is not a DataType field type in DataType: #{datatypename}"
          exit 1
        end
				case dbustype[0].chr
				when "(":
						getList <<= "\tconst #{cpptype}& Get_#{datatypemembername}() const { return (m_data._#{fieldorder}); }\n"
						setList <<= "\tvoid Set_#{datatypemembername}(const #{cpptype}& p_data) { m_data._#{fieldorder} = p_data; }\n"
				when "a":
						getList <<= "\tconst std::vector< #{cpptype} >& Get_#{datatypemembername}() const { return (m_data._#{fieldorder}); }\n"
						setList <<= "\tvoid Set_#{datatypemembername}(const std::vector< #{cpptype} >& p_data) { m_data._#{fieldorder} = p_data; }\n"
				else
						initialization <<= "\t\tm_data._#{fieldorder} = 0;\n"
						getList <<= "\t#{cpptype} Get_#{datatypemembername}() const { return (m_data._#{fieldorder}); }\n"
						setList <<= "\tvoid Set_#{datatypemembername}(#{cpptype} p_data) { m_data._#{fieldorder} = p_data; }\n"
				end

      }
			classname="#{$MarelliNamespace}_#{@servicename}_#{datatypename}"
			$includeFileOut.puts eval( '"' + @classtemplate + '"' )
			end
    }
  end
end
