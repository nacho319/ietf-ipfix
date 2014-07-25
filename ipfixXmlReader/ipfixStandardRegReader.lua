xml = require('LuaXml')



--[[ ******************************************************************

myXmlFind
---------

code liberally borrowed from the LuaXML package by Gerald Franz



LuaXML License

LuaXML is licensed under the terms of the MIT license reproduced below,
the same as Lua itself. This means that LuaXML is free software and can be
used for both academic and commercial purposes at absolutely no cost.

Copyright (C) 2007-2010 by Gerald Franz, www.viremo.de

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

--]]
function myXmlFind(var, tag, attributeKey, attributeValue)
	local base = _G

	-- check the input
    if base.type(var)~="table" then 
		return 
	end
    if base.type(tag)=="string" and #tag==0 then 
		tag=nil 
	end
    if base.type(attributeKey)~="string" or #attributeKey==0 then 
		attributeKey=nil 
	end
    if base.type(attributeValue)=="string" and #attributeValue==0 then 
		attributeValue=nil 
	end

	--
	-- compare the table
	--
    if tag~=nil then
      if var[0]==tag and ( attributeValue == nil or var[attributeKey]==attributeValue ) then
        base.setmetatable(var,{__index=xml, __tostring=xml.str})
        return var,0
      end
    else
      if attributeValue == nil or var[attributeKey]==attributeValue then
        base.setmetatable(var,{__index=xml, __tostring=xml.str})
        return var,0
      end
    end
	
    -- recursively parse subtags:
    for k,v in base.ipairs(var) do
      if base.type(v)=="table" then
        --local ret = find(v, tag, attributeKey,attributeValue)
		local ret,derIndex = myXmlFind(v, tag, attributeKey,attributeValue)
        if ret ~= nil then 
			return ret,derIndex 
		end
      end
    end

end



--[[ ******************************************************************
	recurseRec

	recurse into an XML structure and print it out

--]]
function recurseRec(xRec, indent)
	local stringLine = "\t\t"
		
	if type(xRec)=="table" and #xRec>=1 then
		recurseRec(xRec[0], indent+1)
	else
		for j=1,indent do
			stringLine = stringLine.."\t"
		end

		stringLine = stringLine.."*: "..tostring(xRec)

		print(stringLine)
	end
end


--[[ ******************************************************************
	penieTableExtract

	@param xRec
--]]
function penieTableExtract(xRec)

	for derLop=0,#xRec do
		if type(xRec[derLop])=="table" and #xRec[derLop]>=1 then
			printf("fubar3 -> ",xRec[derLop])
			recurseIpfixInfoElement(xRec, 1000)
		else
			print("fubar -> ",xRec[derLop])
			print("fubar2 -> ",xRec)
		end
	end
	
	
end

--[[ ******************************************************************
	convert an IANA formatted record into a PENIE exchange record

	@param xRec - table that is a hunk of (possibly nested) XML 
                  structure defining part of an Info Element
	@param foo -


--]]
function recurseIpfixInfoElement(xRec, foo)
	if type(xRec)=="table" and #xRec>=1 then
		recurseIpfixInfoElement(xRec[0], foo+1)
	else
		penieTableExtract(xRec)
		--print("bar -> ",foo," ",xRec," (",#xRec,")")
	end
end



--[[
TABLE UTIL

code stolen from Lua wiki

--]]
function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end
-- end TABLE UTIL


--[[ ******************************************************************
	because I want it to look more like C

--]]
function doMain()


	-- read and process the standard IANA IE registry and be able to host 
	-- that registry in registry distribution format
	local ianaRegFile = xml.load("ipfix.xml")

	print (table.tostring(ianaRegFile))
	

	local firstRecord,startIndex = myXmlFind(ianaRegFile, "registry", "id", "ipfix-information-elements")
	--print ("key index: ", startIndex, " registry record table: ", firstRecord)


	-- test code
	for index=1,#firstRecord do
		print("record: ",firstRecord[index])
		for recI=0,#firstRecord[index] do
			local workRec = firstRecord[index][recI]
			print("\t\t\t\ttype is: ",type(workRec),"\tlength",#workRec)
			if type(workRec)=="table" and #workRec>=1 then
				recurseRec(workRec, 2)
			else
				print("\t",recI,": ",workRec)
			end
		end
		print("\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n\n")
	end


	-- code that should eventually drive the real functionality
	for index=1,#firstRecord do
		repeat
			if firstRecord[index][0]~="record" then
				break
			end
			for recI=0,#firstRecord[index] do
				repeat
					local workRec = firstRecord[index][recI]
					if type(workRec)=="table" and #workRec>=1 then
						recurseIpfixInfoElement(workRec, 99)
					else
						penieTableExtract(workRec)
						--print("foo -> ",recI," ",workRec)
					end
				until true
			end
			print("\n\n\n")
		until true
	end


end





--[[ *******************************
	START HERE
--]]
doMain()



