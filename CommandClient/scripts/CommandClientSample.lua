--[[----------------------------------------------------------------------------

  Application Name: CommandClient

  Description:
  TCPIP-Client connection and Command.Client creation using SOPAS ET project.

  This samples creates a TCPIPClient connection to the local address of the device
  itself ("127.0.0.1") and create a Command.Client on the connection using a
  SOPAS ET project ("AppEngine.sopas") of the own device as description.
  After open the device ident variable of the connected device is read and printed
  to the console. Then a login to device is done and the variable location name is
  written. All parameters of the device are backed up then into the file "private/backup.sopas"
  The location name is changed again and the variables are restored from the
  stored "private/backup.sopas" file. After the restore the location name variable
  is checked that it is overwritten again by the restore.
  At the end a logout is done on the device.

  This sample can be run with the emulator. The console is printing the actions
  and a "successfully finished" at the end.
  A file is created in the private AppData folder (refresh). This "backup.sopas" file
  can be downloaded (e.g. drag and drop from the AppData tab) and opened in SOPAS ET.

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------


-- Create and configure the connection
local conHandle = TCPIPClient.create()
TCPIPClient.setIPAddress(conHandle, '127.0.0.1') -- Connect to own AppEngine process
TCPIPClient.setPort(conHandle, 2111)
TCPIPClient.connect(conHandle, 5000) -- wait 5 seconds for connected
assert(TCPIPClient.isConnected(conHandle)) -- connection handling has to be done by the user of the Command.Client

-- Create, configure and open the client
local handle = Command.Client.create()
Command.Client.setDescriptionFile(handle, 'resources/AppEngine.sopas')
Command.Client.setConnection(handle, conHandle)
Command.Client.setProtocol(handle, 'COLA_A')
assert(Command.Client.open(handle))
-- Now the ".sopas"-file is loaded and the client is registered at the connection and can be used

-- read the DeviceIdent from the device and print the name and version
print("Reading variable 'DeviceIdent'")
local paramNode = Command.Client.read(handle, 'DeviceIdent')
if paramNode then
  local devName = Parameters.Node.get(paramNode, 'Name')
  print('Device name is: ' .. devName)
  local devVersion = Parameters.Node.get(paramNode, 'Version')
  print('Device version is: ' .. devVersion)
else
  print('error')
end

-- Login to device to write a variable and make restore possible
print("Login with level 'Authorized Client'")
local node = Command.Client.createNode(handle, 'SetAccessMode')
assert(node)
assert(Parameters.Node.set(node, 3, 'NewMode')) -- userlevel "Authorized Client"
assert(Parameters.Node.set(node, 0xF4724744, 'Password')) -- encoded password "client"
local success,
  result = Command.Client.invoke(handle, 'SetAccessMode', node)
assert(success and result)
assert(Parameters.Node.get(result, 'success'))

-- Write a variable to the device
print("Writing variable 'LocationName'")
node = Command.Client.createNode(handle, 'LocationName')
assert(node)
assert(Parameters.Node.set(node, 'MyDevice'))
success = Command.Client.write(handle, 'LocationName', node)
assert(success)

-- Backup all parameters to a ".sopas" file which can be opened in SOPAS ET
print('Starting backup')
assert(Command.Client.backup(handle, 'private/backup.sopas'))

-- Write a variable to the device to check restoring
print("Writing variable 'LocationName'")
node = Command.Client.createNode(handle, 'LocationName')
assert(node)
assert(Parameters.Node.set(node, 'MyOtherDevice'))
local bsuccess = Command.Client.write(handle, 'LocationName', node)
assert(bsuccess)

-- Restore parameters back to device (login is needed above so that it works)
print('Restoring parameters to device')
assert(Command.Client.restore(handle, 'private/backup.sopas'))

-- Read location name again, is now back to something other
print("Reading variable 'LocationName'")
node = Command.Client.read(handle, 'LocationName')
assert(node)
local name = Parameters.Node.get(node)
assert(name and name == 'MyDevice') -- "MyOtherDevice" is overwritten by restore

-- Logout clearly from the device
print('Logging out from device')
success = Command.Client.invoke(handle, 'Run')
assert(success)

print('CommandClient sample finished successfully')

--End of Global Scope-----------------------------------------------------------
