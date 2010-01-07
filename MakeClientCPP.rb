
def MakeClientCPP (rootname, outdir)
now_time=Time.new
release=ENV['BindingToolRel'].nil? ? "-NOT LEGAL RELEASE-" : ENV['BindingToolRel']

template = <<'SINGLE_QUOTED'
//  Copyright #{now_time.year} (c) Magneti Marelli, Inc., Akhela srl
//  generated with BindingTool rel. #{release}
#include \"C_DBUS_INTERFACE.h\"
#include \"#{rootname}_CLIENT.h\"
#include \"unistd.h\"
using namespace std;


// CONSTRUCTOR
#{rootname}_CLIENT::#{rootname}_CLIENT(DBus::Connection &connection, const char *path, const char *name)
: C_DBUS_INTERFACE(name,path,CLIENT_MODE),
DBus::ObjectProxy(*dbusConnection, path, name)
{
/*
#{$signalConnectionList}
*/
}

#{$signalSkeletonList}


void #{rootname}_CLIENT::callApi(void)
{
/* TO DO */
}
SINGLE_QUOTED



filename="#{outdir}#{rootname}_CLIENT.cpp"
  open(filename, 'w') { |file|
    file.puts eval( '"' + template + '"')
	}
end


