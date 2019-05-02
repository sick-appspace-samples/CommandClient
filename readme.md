## CommandClient
TCPIP-Client connection and Command.Client creation using SOPAS ET project.
### Description
This samples creates a TCPIPClient connection to the local address of the device
itself ("127.0.0.1") and create a Command.Client on the connection using a
SOPAS ET project ("AppEngine.sopas") of the own device as description.
After open the device ident variable of the connected device is read and printed
to the console. Then a login to device is done and the variable location name is
written. All parameters of the device are backed up then into the file "private/backup.sopas"
The location name is changed again and the variables are restored from the
stored "private/backup.sopas" file. After the restore the location name variable
is checked that it is overwritten again by the restore.
At the end a logout is done on the device. This sample can be run with the emulator. 
The console is printing the actions and a "successfully finished" at the end.
A file is created in the private AppData folder (refresh). This "backup.sopas" file
can be downloaded (e.g. drag and drop from the AppData tab) and opened in SOPAS ET

### Topics
System, Communication, Sample, SICK-AppSpace