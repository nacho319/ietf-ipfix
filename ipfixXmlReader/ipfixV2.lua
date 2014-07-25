require('LuaXml')

-- load the file in
local ipfixReg = xml.load("ipfix.xml")

-- find the first record
local record = ipfixReg:find("record")


