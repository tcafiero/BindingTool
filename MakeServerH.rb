
def MakeServerH (rootname, newdescription, outdir)
now_time=Time.new
release=ENV['BindingToolRel'].nil? ? "-NOT LEGAL RELEASE-" : ENV['BindingToolRel']

  codepart1 = <<-EOS
//  Copyright #{now_time.year} (c) Magneti Marelli, Inc., Akhela srl
//  generated with BindingTool rel. #{release}
//
//! @file
//! @brief This file contains the declaration of the class #{rootname}_SERVER
//!
//! @copydoc #{rootname}_SERVER.h

#ifndef #{rootname}_SERVER_H_
#define #{rootname}_SERVER_H_

/*_____ I N C L U D E - F I L E S ____________________________________________*/

#include <dbus-c++/dbus.h>
#include "#{rootname}_adaptor_imp.h"


class #{rootname}_SERVER
: public C_DBUS_INTERFACE,
EOS

codepart2 = <<-EOS
  public DBus::ObjectAdaptor

{
public:


/** constructor, destructor */
	#{rootname}_SERVER(DBus::Connection &connection);
	#{rootname}_SERVER(std::string server_name,std::string server_path);
	#{rootname}_SERVER(const char * server_name,const char * server_path);
	~#{rootname}_SERVER();
	/** method to set variables*/
/*
	void on_set_property (DBus::InterfaceAdaptor &interface, const std::string &property, const DBus::Variant &value);
*/

/** virtual method that have to be implemented */
  /** from C_DBUS_INTERFACE class **/
  virtual void callActionPrivate(int arg1,
                int arg2,
                int arg3,
                int arg4,
                int arg5,
                int arg6,
                int arg7,
                int arg8,
                int arg9,
                int arg10,
                int arg11);

EOS

codepart3 = <<-EOS

};

#endif  // #{rootname}_SERVER_H_

/*_____E N D _____ (#{rootname}_SERVER.h) ________________________________________*/
EOS



filename="#{outdir}#{rootname}_SERVER.h"
  open(filename, 'w') { |file|
    file.puts codepart1
    comma=""
		newdescription.elements.each('Service') { |service|
    service.elements.each('Interface') { |interfaceSingle|
#      name="#{service.attributes['Name']}.#{interfaceSingle.attributes['Name']}"
      name="#{$MarelliNamespace}_#{interfaceSingle.attributes['Name']}"
#			file.print "#{comma}\tpublic #{name.gsub /[\/\.]/, "::"}_adaptor"
			file.print "#{comma}\tpublic #{name}_adaptor_imp"
      comma=",\n"
    }
    file.puts comma
		file.puts codepart2
    #virtual
		file.puts $methodPrototypeList
    #end virtual
    file.puts codepart3
  }
	}
end


