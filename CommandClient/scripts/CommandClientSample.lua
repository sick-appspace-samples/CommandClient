
--Start of Global Scope---------------------------------------------------------


-- Create and configure the connection
local conHandle = TCPIPClient.create()
TCPIPClient.setIPAddress(conHandle, '127.0.0.1') -- Connect to own AppEngine process
TCPIPClient.setPort(conHandle, 2111)
TCPIPClient.connect(conHandle, 5000) -- wait 5 seconds for connected
assert(TCPIPClient.isConnected(conHandle),nil) -- connection handling has to be done by the user of the Command.Client

-- Create, configure and open the client
local handle = Command.Client.create()
Command.Client.setDescriptionFile(handle, 'resources/AppEngine.sopas')
Command.Client.setConnection(handle, conHandle)
Command.Client.setProtocol(handle, 'COLA_A')
assert(Command.Client.open(handle),nil)
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
assert(node,nil)
assert(Parameters.Node.set(node, 3, 'NewMode'),nil) -- userlevel "Authorized Client"
assert(Parameters.Node.set(node, 0xF4724744, 'Password'),nil) -- encoded password "client"
local success,
  result = Command.Client.invoke(handle, 'SetAccessMode', node)
assert(success and result,nil)
assert(Parameters.Node.get(result, 'success'),nil)

-- Write a variable to the device
print("Writing variable 'LocationName'")
node = Command.Client.createNode(handle, 'LocationName')
assert(node,nil)
assert(Parameters.Node.set(node, 'MyDevice'),nil)
success = Command.Client.write(handle, 'LocationName', node)
assert(success,nil)

-- Backup all parameters to a ".sopas" file which can be opened in SOPAS ET
print('Starting backup')
assert(Command.Client.backup(handle, 'private/backup.sopas'),nil)

-- Write a variable to the device to check restoring
print("Writing variable 'LocationName'")
node = Command.Client.createNode(handle, 'LocationName')
assert(node,nil)
assert(Parameters.Node.set(node, 'MyOtherDevice'),nil)
local bsuccess = Command.Client.write(handle, 'LocationName', node)
assert(bsuccess,nil)

-- Restore parameters back to device (login is needed above so that it works)
print('Restoring parameters to device')
assert(Command.Client.restore(handle, 'private/backup.sopas'),nil)

-- Read location name again, is now back to something other
print("Reading variable 'LocationName'")
node = Command.Client.read(handle, 'LocationName')
assert(node,nil)
local name = Parameters.Node.get(node)
assert(name and name == 'MyDevice',nil) -- "MyOtherDevice" is overwritten by restore

-- Logout clearly from the device
print('Logging out from device')
success = Command.Client.invoke(handle, 'Run')
assert(success,nil)

print('CommandClient sample finished successfully')

--End of Global Scope-----------------------------------------------------------
