def MakeClientH (rootname, newdescription, outdir)
now_time=Time.new
release=ENV['BindingToolRel'].nil? ? "-NOT LEGAL RELEASE-" : ENV['BindingToolRel']
  codepart1 = <<-EOS
//  Copyright #{now_time.year} (c) Magneti Marelli, Inc., Akhela srl
//  generated with BindingTool rel. #{release}
//
//! @file
//! @brief This file contains the declaration of the class #{rootname}_CLIENT
//!
//! @copydoc #{rootname}_CLIENT.h

#ifndef #{rootname}_CLIENT_H_
#define #{rootname}_CLIENT_H_

/*_____ I N C L U D E - F I L E S ____________________________________________*/

#include <dbus-c++/dbus.h>
#include "#{rootname}_proxy_imp.h"
#include "CMMString.h"


class #{rootname}_CLIENT
: public C_DBUS_INTERFACE,
EOS

codepart2 = <<-EOS
  public DBus::ObjectProxy

{
public:
	/** constructor */
	#{rootname}_CLIENT(DBus::Connection &connection, const char *path,const char *name);
	void call_method(void);
	#{$signalPrototypeList}
	void callApi(void);
};
#endif  // #{rootname}_CLIENT_H_

/*_____E N D _____ (#{rootname}_CLIENT.h) ________________________________________*/
EOS


filename="#{outdir}#{rootname}_CLIENT.h"
  open(filename, 'w') { |file|
    file.puts codepart1
    comma=""
		newdescription.elements.each('Service') { |service|
    service.elements.each('Interface') { |interfaceSingle|
#      name="#{service.attributes['Name']}.#{interfaceSingle.attributes['Name']}"
      name="#{$MarelliNamespace}_#{interfaceSingle.attributes['Name']}"
#      file.print "#{comma}\tpublic #{name.gsub /[\/\.]/, "::"}_proxy"
      file.print "#{comma}\tpublic #{name}_proxy_imp"
      comma=",\n"
    }
    file.puts comma
    file.puts codepart2
  }
	}
end


