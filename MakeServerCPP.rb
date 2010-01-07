
def MakeServerCPP (rootname, outdir)
now_time=Time.new
release=ENV['BindingToolRel'].nil? ? "-NOT LEGAL RELEASE-" : ENV['BindingToolRel']

template = <<'SINGLE_QUOTED'
//  Copyright #{now_time.year} (c) Magneti Marelli, Inc., Akhela srl
//  generated with BindingTool rel. #{release}
#include \"C_DBUS_INTERFACE.h\"
#include \"#{rootname}_dataType.h\"
#include \"#{rootname}_SERVER.h\"
#include <unistd.h>

using namespace std;

#{rootname}_SERVER::C_BCM_TEST_SERVER(std::string _server_name,std::string _server_path):
C_DBUS_INTERFACE(_server_name,_server_path),
	DBus::ObjectAdaptor(*dbusConnection, _server_path.c_str())
{
	   //TO BE DONE
}

#{rootname}_SERVER::C_BCM_TEST_SERVER(const char * _server_name,const char * _server_path):
	C_DBUS_INTERFACE(_server_name,_server_path),
 DBus::ObjectAdaptor(*dbusConnection, _server_path)
{
	   //TO BE DONE
}

#{rootname}_SERVER::~#{rootname}_SERVER()
{
	   //TO BE DONE
}

void #{rootname}_SERVER::callActionPrivate(int arg1,
 							 int arg2,
               int arg3,
               int arg4,
               int arg5,
               int arg6,
               int arg7,
               int arg8,
               int arg9,
               int arg10,
               int arg11)
{
 	  //TO BE DONE
}

#{$methodSkeletonList}
SINGLE_QUOTED



filename="#{outdir}#{rootname}_SERVER.cpp"
  open(filename, 'w') { |file|
    file.puts eval( '"' + template + '"')
	}
end


